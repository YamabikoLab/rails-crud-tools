module Rails
  module Crud
    class CrudData
      include Singleton

      attr_accessor :crud_rows, :crud_cols, :workbook

      def initialize
        @crud_rows = {}
        @crud_cols = {}
      end

      def load_crud_data
        config = CrudConfig.instance
        return unless config.enabled

        unless File.exist?(config.crud_file_path)
          raise "CRUD file not found: #{config.crud_file_path}"
        end

        @workbook = RubyXL::Parser.parse(config.crud_file_path)
        sheet = @workbook[0]
        headers = sheet[0].cells.map(&:value)

        method_col_index = headers.index(config.method_col)
        action_col_index = headers.index(config.action_col)
        table_start_col_index = headers.index(config.table_start_col)

        raise "Method column not found" unless method_col_index
        raise "Action column not found" unless action_col_index
        raise "Table start column not found" unless table_start_col_index

        headers[table_start_col_index..-1].each_with_index do |table_name, index|
          @crud_cols[table_name] = table_start_col_index + index
        end

        sheet.each_with_index do |row, index|
          next if index == 0

          method = row[method_col_index]&.value
          action = row[action_col_index]&.value&.split&.first
          next unless method && action

          @crud_rows[method] ||= {}
          @crud_rows[method][action] = index
        end
      end
    end
  end
end