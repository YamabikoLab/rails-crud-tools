# frozen_string_literal: true

require "active_support/notifications"

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
          ActiveSupport::Notifications.subscribe(/sql.active_record/) do |_name, _started, _finished, _unique_id, data|
            process_sql(data)
          end
        end

        # 通知の登録が完了した後に @subscribed を true に設定
        @subscribed = true
      end

      OPERATION_UNKNOWN = "Unknown"

      def self.process_sql(data)
        return unless data[:sql] =~ /\A\s*(INSERT|UPDATE|DELETE|SELECT)/i

        case data[:sql]
        when /\bINSERT INTO\b.*\bSELECT\b/i
          handle_insert_select(data)
        when /\bUPDATE\b.*\bSET\b.*\bSELECT\b/i
          handle_update_select(data)
        when /\bDELETE\b.*\bEXISTS\b.*\bSELECT\b/i
          handle_delete_select(data)
        else
          handle_general_sql(data)
        end

        return unless CrudConfig.instance.sql_logging_enabled

        # SQL ログを出力
        CrudLogger.logger.info (data[:sql]).to_s
      end

      def self.handle_insert_select(data)
        # INSERT INTO ... SELECT の特別な処理
        insert_table = data[:sql].match(/INSERT INTO\s+`?(\w+)`?/i)[1]
        select_tables = data[:sql].scan(/SELECT .* FROM\s+`?(\w+)`?(?:\s*,\s*`?(\w+)`?)*|JOIN\s+`?(\w+)`?/i).flatten.compact

        key, method = determine_key_and_method
        if key.nil? || method.nil?
          CrudLogger.logger.warn "Request not found. #{data[:sql]}"
          return
        end

        CrudOperations.instance.add_operation(method, key, insert_table, "C")
        select_tables.each do |select_table|
          CrudOperations.instance.add_operation(method, key, select_table, "R")
        end
      end

      def self.handle_update_select(data)
        # UPDATE ... SET ... SELECT の特別な処理
        update_table = data[:sql].match(/UPDATE\s+`?(\w+)`?/i)[1]
        select_tables = data[:sql].scan(/SELECT .* FROM\s+`?(\w+)`?(?:\s*,\s*`?(\w+)`?)*|JOIN\s+`?(\w+)`?/i).flatten.compact

        key, method = determine_key_and_method
        if key.nil? || method.nil?
          CrudLogger.logger.warn "Request not found. #{data[:sql]}"
          return
        end

        CrudOperations.instance.add_operation(method, key, update_table, "U")
        select_tables.each do |select_table|
          CrudOperations.instance.add_operation(method, key, select_table, "R")
        end
      end

      def self.handle_delete_select(data)
        # DELETE ... WHERE EXISTS ... SELECT の特別な処理
        delete_table = data[:sql].match(/DELETE FROM\s+`?(\w+)`?/i)[1]
        select_tables = data[:sql].scan(/SELECT .* FROM\s+`?(\w+)`?(?:\s*,\s*`?(\w+)`?)*|JOIN\s+`?(\w+)`?/i).flatten.compact

        key, method = determine_key_and_method
        if key.nil? || method.nil?
          CrudLogger.logger.warn "Request not found. #{data[:sql]}"
          return
        end

        CrudOperations.instance.add_operation(method, key, delete_table, "D")
        select_tables.each do |select_table|
          CrudOperations.instance.add_operation(method, key, select_table, "R")
        end
      end

      def self.handle_general_sql(data)
        operation = if (match = data[:sql].match(/\A\s*(INSERT|UPDATE|DELETE|SELECT)/i))
                      case match[1].upcase
                      when "INSERT" then "C"
                      when "SELECT" then "R"
                      when "UPDATE" then "U"
                      when "DELETE" then "D"
                      else OPERATION_UNKNOWN
                      end
                    else
                      OPERATION_UNKNOWN
                    end

        if operation == OPERATION_UNKNOWN
          warn "Warning: Unknown SQL operation. SQL: #{data[:sql]}"
          return
        end

        table_names = data[:sql].scan(/(?:INSERT INTO|UPDATE|DELETE FROM|FROM|JOIN)\s+`?(\w+)`?(?:\s*,\s*`?(\w+)`?)*/i).flatten.compact
        if table_names.empty?
          # テーブル名が見つからない場合は警告を出力
          CrudLogger.logger.warn "Table name not found in SQL: #{data[:sql]}"
          return
        end

        key, method = determine_key_and_method
        if key.nil? || method.nil?
          CrudLogger.logger.warn "Request not found. #{data[:sql]}"
          return
        end

        # テーブル名を取得して CRUD 操作に追加
        table_names.each do |table_name|
          CrudOperations.instance.add_operation(method, key, table_name, operation)
        end
      end
      # キーとメソッドを決定する
      def self.determine_key_and_method
        request = Thread.current[:crud_request]
        sidekiq_job_class = Thread.current[:crud_sidekiq_job_class]

        if request
          method = request.request_method
          controller = request.params["controller"]
          action = request.params["action"]
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
