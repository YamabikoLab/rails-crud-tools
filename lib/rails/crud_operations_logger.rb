module Rails
  module Crud
    module OperationsLogger
      def log_crud_operations
        if $crud_config.enabled
          $table_operations = {}
          sql_log_file = Rails.root.join($crud_config.base_dir, $crud_config.sql_log)
          method = request.request_method
          File.open(sql_log_file, 'w') do |file|
            file.puts "Method: #{method}, Controller: #{controller_path}, Action: #{action_name}, Key: #{controller_path}##{action_name}"
          end
        end

        yield

        if $crud_config.enabled
          Thread.new do
            sheet = $workbook[0]
            headers = sheet[0].cells.map(&:value)

            $table_operations.each_key do |table_name|
              row = $crud_rows[method]["#{controller_path}##{action_name}"]
              col = $crud_cols[table_name]

              # colまたはrowが存在しない場合にログ出力してスキップ
              unless row && col
                Rails.logger.warn "Row or Column not found for table: #{table_name}, method: #{method}, controller: #{controller_path}, action: #{action_name}, row: #{row}, col: #{col}"
                next
              end
              # 既存の値を取得
              existing_value = sheet[row][col].value || ""

              # 新しい値と既存の値を結合し、重複を排除
              new_value = $table_operations[table_name].join
              merged_value = (existing_value.chars + new_value.chars).uniq

              # CRUDの順序に並び替え
              crud_order = %w[C R U D]
              sorted_value = merged_value.sort_by { |char| crud_order.index(char) }.join

              # 結合した値をセルに設定
              sheet[row][col].change_contents(sorted_value)
            end

            # Excelファイルを書き込む
            $workbook.write($crud_config.crud_file_path)

            File.open(sql_log_file, 'a') do |file|
              file.puts "\nSummary:"
              $table_operations.each do |table_name, operations|
                file.puts "#{table_name} - #{operations.join(', ')}"
              end
            end
          end
        end
      end
    end
  end
end