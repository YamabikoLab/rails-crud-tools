require_relative 'crud_logger'

module Rails
  module Crud
    class CrudOperations
      include Singleton

      attr_accessor :table_operations, :logs

      def initialize(logger: CrudLogger.logger)
        @table_operations = {}
        @logger = logger
      end

      def add_operation(table_name, operation)
        @table_operations[table_name] ||= []
        @table_operations[table_name] << operation unless @table_operations[table_name].include?(operation)
      end

      def log_operations(key, method = nil)
        log_summary(key, method)
        log_table_operations
      end

      private

      def log_summary(key, method)
        if method
          @logger.info "\nSummary: Method: #{method}, Key: #{key}"
        else
          @logger.info "\nSummary: Key: #{key}"
        end
      end

      def log_table_operations
        @table_operations.each do |table_name, operations|
          @logger.info "#{table_name} - #{operations.join(', ')}"
        end
      end
    end
  end
end