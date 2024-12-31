require_relative 'crud_logger'
require_relative 'constants'

module Rails
  module Crud
    module Tools
      class CrudOperations
        include Singleton

        attr_accessor :table_operations, :logs

        def initialize
          @table_operations = Hash.new { |hash, key| hash[key] = Hash.new { |h, k| h[k] = Hash.new { |hh, kk| hh[kk] = [] } } }
        end

        def add_operation(table_name, operation)
          request = Thread.current[:request]
          if request
            method = request.request_method
            controller = request.params['controller']
            action = request.params['action']
            key = "#{controller}##{action}"
          elsif Thread.current[:sidekiq_job_class]
            key = Thread.current[:sidekiq_job_class]
            method = Constants::DEFAULT_METHOD
          else
            CrudLogger.logger.warn "Unknown method and key detected"
            return
          end

          @table_operations[method][key][table_name] << operation unless @table_operations[method][key][table_name].include?(operation)
        end

        def log_operations(key, method = nil)
          if method
            CrudLogger.logger.info "\nSummary: Method: #{method}, Key: #{key}"
          else
            CrudLogger.logger.info "\nSummary: Key: #{key}"
          end

          @table_operations[method][key]&.each do |table_name, operations|
            CrudLogger.logger.info "#{table_name} - #{operations.join(', ')}"
          end
        end
      end
    end
  end
end