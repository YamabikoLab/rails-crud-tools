require_relative 'crud_logger'
require_relative 'constants'

module Rails
  module Crud
    class OperationsLogger
      def initialize(logger: CrudLogger.logger, config: CrudConfig.instance, data: CrudData.instance)
        @logger = logger
        @config = config
        @data = data
      end

      def log_crud_operations
        if @config.enabled
          initialize_crud_operations
          log_request_details
        end

        yield

        if @config.enabled
          key = "#{controller_path}##{action_name}"
          method = request.request_method
          CrudOperations.instance.log_operations(key, method)
          log_and_write_operations(key, method)
        end
      end

      def log_crud_operations_for_job
        if @config.enabled
          initialize_crud_operations
          log_job_details
        end

        yield

        if @config.enabled
          key = self.class.name
          CrudOperations.instance.log_operations(key)
          log_and_write_operations(key)
        end
      end

      private

      def initialize_crud_operations
        CrudOperations.instance.table_operations = {}
      end

      def log_request_details
        method = request.request_method
        @logger.info "******************** Method: #{method}, Controller: #{controller_path}, Action: #{action_name}, Key: #{controller_path}##{action_name} ********************"
      end

      def log_job_details
        job_name = self.class.name
        @logger.info "******************** Job: #{job_name} ********************"
      end

      def log_and_write_operations(key, method = nil)
        @data.reload_if_needed
        sheet = @data.workbook[0]

        table_operations_copy = CrudOperations.instance.table_operations.dup
        method_copy = method.nil? ? Constants::DEFAULT_METHOD : method.dup
        key_copy = key.dup

        table_operations_copy.each_key do |table_name|
          row = @data.crud_rows[method_copy][key_copy]
          col = @data.crud_cols[table_name]

          unless row && col
            @logger.warn "Row or Column not found for table: #{table_name}, method: #{method_copy}, key: #{key_copy}, row: #{row}, col: #{col}"
            next
          end

          cell = sheet[row][col]
          if cell.nil?
            cell = sheet.add_cell(row, col, "")
            @logger.warn "Cell not found at row: #{row}, col: #{col} for table: #{table_name}, method: #{method_copy}, key: #{key_copy}. Adding new cell."
            existing_value = ""
          else
            existing_value = cell.value || ""
          end

          new_value = table_operations_copy[table_name].join
          merged_value = (existing_value.chars + new_value.chars).uniq

          crud_order = %w[C R U D]
          sorted_value = merged_value.sort_by { |char| crud_order.index(char) }.join

          cell.change_contents(sorted_value)
        end

        @data.workbook.write(@config.crud_file_path)
        timestamp = File.mtime(@config.crud_file_path)
        @logger.debug "Updated timestamp: #{timestamp}"
        @data.instance_variable_set(:@last_loaded_time, timestamp)
      end
    end
  end
end