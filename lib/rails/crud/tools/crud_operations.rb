require_relative "crud_logger"
require_relative "constants"

module Rails
  module Crud
    module Tools
      # The CrudOperations class is responsible for managing CRUD operations for different tables.
      # It stores operations in a nested hash structure and provides methods to add and log operations.
     class CrudOperations
        include Singleton

        attr_accessor :table_operations, :logs

        def initialize
          @table_operations = Hash.new do |hash, method|
            hash[method] = Hash.new do |h, key|
              h[key] = Hash.new do |hh, table|
                hh[table] = []
              end
            end
          end
        end

        def add_operation(method, key, table_name, operation)
          # @table_operations[method]が存在しない場合は初期化
          @table_operations[method] ||= {}
          # @table_operations[method][key]が存在しない場合は初期化
          @table_operations[method][key] ||= {}
          # @table_operations[method][key][table_name]が存在しない場合は初期化
          @table_operations[method][key][table_name] ||= []

          @table_operations[method][key][table_name] << operation unless @table_operations[method][key][table_name].include?(operation)
        end

        def log_operations(method, key)
          CrudLogger.logger.info "\nSummary: Method: #{method}, Key: #{key}"

          @table_operations[method][key].each do |table_name, operations|
            CrudLogger.logger.info "#{table_name} - #{operations.join(", ")}"
          end

        end

        def table_operations_present?(method, key)
          return false if @table_operations[method].nil?
          return false if @table_operations[method][key].nil?
          !@table_operations[method][key].empty?
        end
      end
    end
  end
end