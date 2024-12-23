require_relative "crud_config"
require_relative 'crud_logger'

module Rails
  module Crud
    def self.setup_notifications
      if CrudConfig.enabled
        ActiveSupport::Notifications.subscribe(/sql.active_record/) do |name, started, finished, unique_id, data|
          if data[:sql] =~ /(INSERT|UPDATE|DELETE|SELECT)/
            operation = case $1
                        when "INSERT" then "C"
                        when "UPDATE" then "U"
                        when "DELETE" then "D"
                        when "SELECT" then "R"
                        else "Unknown"
                        end

            table_name = data[:sql].match(/(?:INSERT INTO|UPDATE|DELETE FROM|FROM)\s+`?(\w+)`?/i)[1]

            # CrudOperations インスタンスを使用して操作を追加
            CrudOperations.instance.add_operation(table_name, operation)

            CrudLogger.logger.info "#{data[:name]} - #{data[:sql]}"
          end
        end
      end
    end
  end
end