require 'active_support/notifications'

# Notification を使用して SQL クエリを監視するためのモジュール
module Rails
  module Crud
    module Tools
      def self.setup_notifications
        if CrudConfig.enabled
          # SQL クエリを監視する
          ActiveSupport::Notifications.subscribe(/sql.active_record/) do |name, started, finished, unique_id, data|
            # INSERT, UPDATE, DELETE, SELECT のみを対象とする
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
                # テーブル名を取得して CRUD 操作に追加
                table_name = match_data[1]

                request = Thread.current[:crud_request]
                if request
                  method = request.request_method
                  controller = request.params['controller']
                  action = request.params['action']
                  key = "#{controller}##{action}"
                elsif Thread.current[:crud_sidekiq_job_class]
                  key = Thread.current[:crud_sidekiq_job_class]
                  method = Constants::DEFAULT_METHOD
                else
                  CrudLogger.logger.warn "Unknown method and key detected"
                  return
                end

                CrudOperations.instance.add_operation(method, key, table_name, operation)

                if CrudConfig.instance.sql_logging_enabled
                  # SQL ログを出力
                  CrudLogger.logger.info "#{data[:name]} - #{data[:sql]}"
                end
              else
                # テーブル名が見つからない場合は警告を出力
                CrudLogger.logger.warn "Table name not found in SQL: #{data[:sql]}"
              end
            end
          end
        end
      end
    end
  end
end