require 'active_support/notifications'

# Notification を使用して SQL クエリを監視するためのモジュール
module Rails
  module Crud
    module Tools
      def self.setup_notifications
        # 初回呼び出し時に @subscribed を false に設定
        @subscribed ||= false
        # 既に通知が登録されている場合は処理を中断
        return if @subscribed

        config = CrudConfig.instance
        if config.enabled
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
                key, method = determine_key_and_method
                next if key.nil? || method.nil?

                CrudOperations.instance.add_operation(method, key, table_name, operation)

                next unless config.sql_logging_enabled

                # SQL ログを出力
                CrudLogger.logger.info "#{data[:name]} - #{data[:sql]}"
              else
                # テーブル名が見つからない場合は警告を出力
                CrudLogger.logger.warn "Table name not found in SQL: #{data[:sql]}"
              end
            end
          end
        end

        # 通知の登録が完了した後に @subscribed を true に設定
        @subscribed = true
      end

      private

      # キーとメソッドを決定する
      def self.determine_key_and_method
        request = Thread.current[:crud_request]
        sidekiq_job_class = Thread.current[:crud_sidekiq_job_class]

        if request
          method = request.request_method
          controller = request.params['controller']
          action = request.params['action']
          key = "#{controller}##{action}"
        elsif sidekiq_job_class
          key = sidekiq_job_class
          method = Constants::DEFAULT_METHOD
        else
          CrudLogger.logger.warn "Unknown method and key detected: method=#{method}, key=#{key}"
          return nil
        end

        [key, method]
      end

    end
  end
end