# frozen_string_literal: true

require "zip"
require_relative "crud_logger"
require_relative "constants"
require 'fileutils'

module Rails
  module Crud
    module Tools
      # The OperationsLogger module is responsible for logging CRUD operations in controllers and jobs.
      # It provides methods to log request and job details, and to write CRUD operations to an Excel file.
      module OperationsLogger
        # コントローラのCRUD操作をログ出力する
        def log_crud_operations
          config = CrudConfig.instance.config
          if config.enabled
            CrudConfig.instance.load_config
            log_request_details
            Thread.current[:crud_request] = request
          end

          yield

          if config.enabled
            key = "#{controller_path}##{action_name}"
            method = request.request_method
            if CrudOperations.instance.table_operations_present?(method, key)
              CrudOperations.instance.log_operations(method, key)
              log_and_write_operations(method, key)
            end
          end
        ensure
          Thread.current[:crud_request] = nil
        end

        # ジョブのCRUD操作をログ出力する
        def log_crud_operations_for_job
          config = CrudConfig.instance.config
          if config.enabled
            CrudConfig.instance.load_config
            log_job_details
            key = self.class.name
            Thread.current[:crud_sidekiq_job_class] = key
          end

          yield

          if config.enabled && CrudOperations.instance.table_operations_present?(Constants::DEFAULT_METHOD, key)
            CrudOperations.instance.log_operations(Constants::DEFAULT_METHOD, key)
            log_and_write_operations(Constants::DEFAULT_METHOD, key)
          end
        ensure
          Thread.current[:crud_sidekiq_job_class] = nil
        end

        # xlsxファイルの最終更新者を更新する
        def set_last_modified_by(file_path, modifier_name)
          CrudLogger.logger.debug "Starting to read/write ZIP file: #{file_path}"
          CrudLogger.logger.debug "File size: #{File.size(file_path)}"

          begin
            File.open(file_path, "r+") do |f|
              f.flock(File::LOCK_EX)
              begin
                Zip::File.open(file_path) do |zip_file|
                  doc_props = zip_file.find_entry("docProps/core.xml")
                  if doc_props
                    content = doc_props.get_input_stream.read
                    updated_content = if content.include?("<cp:lastModifiedBy>")
                                      content.sub(
                                        %r{<cp:lastModifiedBy>.*?</cp:lastModifiedBy>},
                                        "<cp:lastModifiedBy>#{modifier_name}</cp:lastModifiedBy>"
                                      )
                                    else
                                      content.sub(
                                        %r{</cp:coreProperties>},
                                        "<cp:lastModifiedBy>#{modifier_name}</cp:lastModifiedBy></cp:coreProperties>"
                                      )
                                    end
                    zip_file.get_output_stream("docProps/core.xml") { |f| f.write(updated_content) }
                    CrudLogger.logger.info "Set the last modifier to #{modifier_name}."
                  else
                    CrudLogger.logger.warn "docProps/core.xml was not found."
                  end
                end
              ensure
                f.flock(File::LOCK_UN)
              end
            end
          rescue StandardError => e
            CrudLogger.logger.error "Error occurred: #{e.message}. Restoring from backup."
            FileUtils.mv(backup_path, file_path)
          ensure
            FileUtils.rm_f(backup_path) if File.exist?(backup_path)
          end
        end

        private

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
        def log_and_write_operations(method, key)
          CrudData.instance.reload_if_needed
          sheet = CrudData.instance.crud_sheet

          # フラグを初期化
          contents_changed = false

          CrudOperations.instance.table_operations[method][key].each_key do |table_name|
            row = CrudData.instance.crud_rows[method][key]
            col = CrudData.instance.crud_cols[table_name]

            # colまたはrowが存在しない場合にログ出力してスキップ
            unless row && col
              CrudLogger.logger.warn "Row or Column not found for table: #{table_name}, method: #{method}, key: #{key}, row: #{row}, col: #{col}"
              next
            end

            # sheet[row][col]がnilの場合に警告文を出力し、空文字列として処理を進める
            cell = sheet[row][col]
            if cell.nil?
              cell = sheet.add_cell(row, col, "")
              CrudLogger.logger.warn "Cell not found at row: #{row}, col: #{col} for table: #{table_name}, method: #{method}, key: #{key}. Adding new cell."
              existing_value = ""
            else
              existing_value = cell.value || ""
            end

            # 新しい値と既存の値を結合し、重複を排除
            new_value = CrudOperations.instance.table_operations[method][key][table_name].join
            merged_value = (existing_value.chars + new_value.chars).uniq

            # CRUDの順序に並び替え
            crud_order = %w[C R U D]
            sorted_value = merged_value.sort_by { |char| crud_order.index(char) }.join

            # 値が変化した場合のみ change_contents を実行
            if cell.value != sorted_value
              cell.change_contents(sorted_value)
              contents_changed = true
            end
          end

          return unless contents_changed

          Thread.new do
            update_crud_file
          rescue StandardError => e
            CrudLogger.logger.error "Failed to update #{CrudConfig.instance.config.crud_file_path}: #{e.message}\n#{e.backtrace.join("\n")}"
          end
        end

        def update_crud_file
          File.open(CrudConfig.instance.config.crud_file_path, "r+") do |crud_file|
            crud_file.flock(File::LOCK_EX)
            begin
              # Excelファイルを書き込む
              CrudData.instance.workbook.write(crud_file)
              timestamp = File.mtime(crud_file)
              # タイムスタンプを更新する
              CrudData.instance.last_loaded_time = timestamp
              CrudLogger.logger.info "Updated timestamp: #{timestamp}"
            ensure
              crud_file.flock(File::LOCK_UN)
            end
          end

          # バックアップを作成
          backup_path = "#{CrudConfig.instance.config.crud_file_path}.bak"
          FileUtils.cp(CrudConfig.instance.config.crud_file_path, backup_path)

          begin
            # 最終更新者を設定
            set_last_modified_by(CrudConfig.instance.config.crud_file_path, CrudData.instance.process_id)
          rescue StandardError => e
            CrudLogger.logger.error "Error occurred: #{e.message}. Restoring from backup."
            CrudLogger.logger.error e.backtrace.join("\n")
            FileUtils.mv(backup_path, CrudConfig.instance.config.crud_file_path)
          ensure
            FileUtils.rm_f(backup_path) if File.exist?(backup_path)
          end
        end
      end
    end
  end
end
