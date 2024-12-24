require_relative 'crud_logger'

# ログ出力を行うモジュール
module Rails
  module Crud
    module OperationsLogger

      # コントローラのCRUD操作をログ出力する
      def log_crud_operations
        if CrudConfig.instance.enabled
          initialize_crud_operations
          log_request_details
        end

        yield

        if CrudConfig.instance.enabled
          CrudOperations.instance.log_operations
          table_operations_copy = CrudOperations.instance.table_operations.dup
          method_copy = request.request_method.dup
          controller_path_copy = controller_path.dup
          action_name_copy = action_name.dup

          log_and_write_operations(method_copy, controller_path_copy, action_name_copy, table_operations_copy)
        end
      end

      # ジョブのCRUD操作をログ出力する
      def log_crud_operations_for_job
        if CrudConfig.instance.enabled
          initialize_crud_operations
          log_job_details
        end

        yield

        if CrudConfig.instance.enabled
          CrudOperations.instance.log_operations
          table_operations_copy = CrudOperations.instance.table_operations.dup
          action_name_copy = self.class.name.dup
          log_and_write_operations("", "", action_name_copy, table_operations_copy)
        end
      end

      private

      # CRUD操作を初期化する
      def initialize_crud_operations
        CrudOperations.instance.table_operations = {}
      end

      # リクエストの詳細をログ出力する
      def log_request_details
        method = request.request_method
        CrudLogger.logger.info "******************************************************************************************************************************************************"
        CrudLogger.logger.info "******************** Method: #{method}, Controller: #{controller_path}, Action: #{action_name}, Key: #{controller_path}##{action_name}"
        CrudLogger.logger.info "******************************************************************************************************************************************************"
      end

      # ジョブの詳細をログ出力する
      def log_job_details
        job_name = self.class.name
        CrudLogger.logger.info "******************************************************************************************************************************************************"
        CrudLogger.logger.info "******************** Job: #{job_name}"
        CrudLogger.logger.info "******************************************************************************************************************************************************"
      end

      # CRUD操作をログ出力し、Excelファイルに書き込む
      def log_and_write_operations(method, controller_path, action_name, table_operations)

        Thread.new do
          sheet = CrudData.instance.workbook[0]

          table_operations.each_key do |table_name|
            row = CrudData.instance.crud_rows[method]["#{controller_path}##{action_name}"]
            col = CrudData.instance.crud_cols[table_name]

            # colまたはrowが存在しない場合にログ出力してスキップ
            unless row && col
              CrudLogger.logger.warn "Row or Column not found for table: #{table_name}, method: #{method}, controller: #{controller_path}, action: #{action_name}, row: #{row}, col: #{col}"
              next
            end

            # 新しい値と既存の値を結合し、重複を排除
            existing_value = sheet[row][col].value || ""
            new_value = table_operations[table_name].join
            merged_value = (existing_value.chars + new_value.chars).uniq

            # CRUDの順序に並び替え
            crud_order = %w[C R U D]
            sorted_value = merged_value.sort_by { |char| crud_order.index(char) }.join

            sheet[row][col].change_contents(sorted_value)
          end

          # Excelファイルを書き込む
          CrudData.instance.workbook.write(CrudConfig.instance.crud_file_path)
        end
      end
    end
  end
end