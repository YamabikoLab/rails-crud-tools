require 'active_support'

module Rails
  module Crud
    def self.setup_notifications
      if CrudConfig.enabled
        subscribe_to_notifications
      end
    end

    def self.subscribe_to_notifications
      ActiveSupport::Notifications.subscribe(/sql.active_record/) do |name, started, finished, unique_id, data|
        if data[:sql] =~ /(INSERT|UPDATE|DELETE|SELECT)/
          operation = case $1
                      when "INSERT" then "C"
                      when "UPDATE" then "U"
                      when "DELETE" then "D"
                      when "SELECT" then "R"
                      else "Unknown"
                      end

          match_data = data[:sql].match(/(?:INSERT INTO|UPDATE|DELETE FROM|FROM)\s+`?(\w+)`?/i)
          if match_data
            table_name = match_data[1]
            CrudOperations.instance.add_operation(table_name, operation)

            if CrudConfig.instance.sql_logging_enabled
              CrudLogger.logger.info "#{data[:name]} - #{data[:sql]}"
            end
          else
            CrudLogger.logger.warn "Table name not found in SQL: #{data[:sql]}"
          end
        end
      end
    end
  end
end