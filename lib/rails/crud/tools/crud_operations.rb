require_relative 'crud_logger'

module Rails
  module Crud
    module Tools
      class CrudOperations
        include Singleton

        attr_accessor :table_operations, :logs

        def initialize
          @table_operations = {}
        end

        def add_operation(table_name, operation)
          @table_operations[table_name] ||= []
          @table_operations[table_name] << operation unless @table_operations[table_name].include?(operation)
        end

        def log_operations(key, method = nil)
          if method
            CrudLogger.logger.info "\nSummary: Method: #{method}, Key: #{key}"
          else
            CrudLogger.logger.info "\nSummary: Key: #{key}"
          end

          @table_operations.each do |table_name, operations|
            CrudLogger.logger.info "#{table_name} - #{operations.join(', ')}"
          end
        end
      end
    end
  end
end