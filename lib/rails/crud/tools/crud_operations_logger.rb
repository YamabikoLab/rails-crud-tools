require_relative 'crud_logger'
require_relative 'constants'

# ログ出力を行うモジュール
module Rails
  module Crud
    module Tools
      module OperationsLogger

        # コントローラのCRUD操作をログ出力する
        def log_crud_operations
          if CrudConfig.instance.enabled
            initialize_crud_operations
            log_request_details
            Thread.current[:crud_request] = request
          end

          yield

          if CrudConfig.instance.enabled
            key = "#{controller_path}##{action_name}"
            method = request.request_method
            if CrudOperations.instance.table_operations_present?(method, key)
              CrudOperations.instance.log_operations(key, method)
              log_and_write_operations(key, method)
            end
          end
        ensure
          Thread.current[:crud_request] = nil
        end

        # ジョブのCRUD操作をログ出力する
        def log_crud_operations_for_job
          if CrudConfig.instance.enabled
            initialize_crud_operations
            log_job_details
            key = self.class.name
            Thread.current[:crud_sidekiq_job_class] = key
          end

          yield

          if CrudConfig.instance.enabled
            if CrudOperations.instance.table_operations_present?(Constants::DEFAULT_METHOD, key)
              CrudOperations.instance.log_operations(key)
              log_and_write_operations(key)
            end
          end
        ensure
          Thread.current[:crud_sidekiq_job_class] = nil
        end

        private

        # CRUD操作を初期化する
        def initialize_crud_operations
          CrudOperations.instance.table_operations = {}
        end

        # リクエストの詳細をログ出力する
        def log_request_details
          method = request.request_method
          CrudLogger.logger.info "******************** Method: #{method}, Controller: #{controller_path}, Action: #{action_name}, Key: #{controller_path}##{action_name} ********************"
        end

        # ジョブの詳細をログ出力する
        def log_job_details
          job_name = self.class.name
          CrudLogger.logger.info "******************** Job: #{job_name} ********************"
        end

        # ExcelファイルにCRUD操作を書き込む
        def log_and_write_operations(key, method = nil)
          CrudData.instance.reload_if_needed
          sheet = CrudData.instance.workbook[0]

          table_operations_copy = CrudOperations.instance.table_operations[method][key].dup
          method_copy = method.nil? ? Constants::DEFAULT_METHOD : method.dup
          key_copy = key.dup

          Thread.new do
            table_operations_copy.each_key do |table_name|
              row = CrudData.instance.crud_rows[method_copy][key_copy]
              col = CrudData.instance.crud_cols[table_name]

              # colまたはrowが存在しない場合にログ出力してスキップ
              unless row && col
                CrudLogger.logger.warn "Row or Column not found for table: #{table_name}, method: #{method_copy}, key: #{key_copy}, row: #{row}, col: #{col}"
                next
              end

              # sheet[row][col]がnilの場合に警告文を出力し、空文字列として処理を進める
              cell = sheet[row][col]
              if cell.nil?
                cell = sheet.add_cell(row, col, "")
                CrudLogger.logger.warn "Cell not found at row: #{row}, col: #{col} for table: #{table_name}, method: #{method_copy}, key: #{key_copy}. Adding new cell."
                existing_value = ""
              else
                existing_value = cell.value || ""
              end

              # 新しい値と既存の値を結合し、重複を排除
              new_value = table_operations_copy[table_name].join
              merged_value = (existing_value.chars + new_value.chars).uniq

              # CRUDの順序に並び替え
              crud_order = %w[C R U D]
              sorted_value = merged_value.sort_by { |char| crud_order.index(char) }.join

              cell.change_contents(sorted_value)
            end

            # Excelファイルを書き込む
            CrudData.instance.workbook.write(CrudConfig.instance.crud_file_path)
            timestamp = File.mtime(CrudConfig.instance.crud_file_path)
            CrudLogger.logger.debug "Updated timestamp: #{timestamp}"
            # タイムスタンプを更新する
            CrudData.instance.instance_variable_set(:@last_loaded_time, timestamp)
          end
        end
      end
    end
  end
end