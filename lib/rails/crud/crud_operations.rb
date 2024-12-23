module Rails
  module Crud
    class CrudOperations
      include Singleton

      attr_accessor :table_operations, :logs

      def initialize
        @table_operations = {}
        @logs = []
        @logger = Logger.new('log/crud.log')
      end

      def add_operation(table_name, operation)
        @table_operations[table_name] ||= []
        @table_operations[table_name] << operation unless @table_operations[table_name].include?(operation)
      end

      def add_log(log_entry)
        @logs << log_entry
      end

      def log_operations()
        @logs.each do |log_entry|
          @logger.info log_entry
        end

        logger.info "\nSummary:"
        @table_operations.each do |table_name, operations|
          @logger.info "#{table_name} - #{operations.join(', ')}"
        end
      end
    end
  end
end