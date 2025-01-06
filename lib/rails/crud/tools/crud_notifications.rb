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

        if CrudConfig.instance.enabled
          # SQL クエリを監視する
          ActiveSupport::Notifications.subscribe(/sql.active_record/) do |name, started, finished, unique_id, data|
            process_sql(data)
          end
        end

        # 通知の登録が完了した後に @subscribed を true に設定
        @subscribed = true
      end


      def self.process_sql(data)
        return unless data[:sql] =~ /(INSERT|UPDATE|DELETE|SELECT)/

        operation = case ::Regexp.last_match(1)
                    when "INSERT" then "C"
                    when "SELECT" then "R"
                    when "UPDATE" then "U"
                    when "DELETE" then "D"
                    else "Unknown"
                    end

        match_data = data[:sql].match(/(?:INSERT INTO|UPDATE|DELETE FROM|FROM)\s+`?(\w+)`?/i)
        if match_data
          # テーブル名を取得して CRUD 操作に追加
          table_name = match_data[1]
          key, method = determine_key_and_method
          if key.nil? || method.nil?
            CrudLogger.logger.warn "Request not found. #{data[:name]} - #{data[:sql]}"
            return
          end

          CrudOperations.instance.add_operation(method, key, table_name, operation)

          return unless CrudConfig.instance.sql_logging_enabled

          # SQL ログを出力
          CrudLogger.logger.info "#{data[:name]} - #{data[:sql]}"
        else
          # テーブル名が見つからない場合は警告を出力
          CrudLogger.logger.warn "Table name not found in SQL: #{data[:sql]}"
        end
      end

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
          return nil
        end

        [key, method]
      end

    end
  end
end