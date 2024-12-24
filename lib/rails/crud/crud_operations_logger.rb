require_relative 'crud_logger'

module Rails
  module Crud
    module OperationsLogger
      def log_crud_operations
        if CrudConfig.instance.enabled
          CrudOperations.instance.table_operations = {}
          method = request.request_method
          CrudLogger.logger.info "******************** Method: #{method}, Controller: #{controller_path}, Action: #{action_name}, Key: #{controller_path}##{action_name} ********************"
        end

        yield

        CrudOperations.instance.log_operations

        table_operations_copy = CrudOperations.instance.table_operations.dup
        method_copy = method.dup
        controller_path_copy = controller_path.dup
        action_name_copy = action_name.dup

        if CrudConfig.instance.enabled
          Thread.new do
            sheet = CrudData.instance.workbook[0]

            table_operations_copy.each_key do |table_name|
              row = CrudData.instance.crud_rows[method_copy]["#{controller_path_copy}##{action_name_copy}"]
              col = CrudData.instance.crud_cols[table_name]

              # colまたはrowが存在しない場合にログ出力してスキップ
              unless row && col
                CrudLogger.logger.warn "Row or Column not found for table: #{table_name}, method: #{method_copy}, controller: #{controller_path_copy}, action: #{action_name_copy}, row: #{row}, col: #{col}"
                next
              end

              existing_value = sheet[row][col].value || ""

              # 新しい値と既存の値を結合し、重複を排除
              new_value = table_operations_copy[table_name].join
              merged_value = (existing_value.chars + new_value.chars).uniq

              # CRUDの順序に並び替え
              crud_order = %w[C R U D]
              sorted_value = merged_value.sort_by { |char| crud_order.index(char) }.join

              # 結合した値をセルに設定
              sheet[row][col].change_contents(sorted_value)
            end

            # Excelファイルを書き込む
            CrudData.instance.workbook.write(CrudConfig.instance.crud_file_path)
          end
        end
      end
    end
  end
end