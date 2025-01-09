# frozen_string_literal: true

require "zip"
require_relative "crud_logger"
require_relative "constants"

module Rails
  module Crud
    module Tools
      # The CrudData class is responsible for loading and managing CRUD data from a file.
      # It includes methods to load data, reload if needed, and retrieve specific information from the data.
      class CrudData
        include Singleton

        attr_accessor :process_id, :crud_rows, :crud_cols, :workbook, :last_loaded_time

        def initialize
          @process_id = nil
          @crud_rows = {}
          @crud_cols = {}
          @last_loaded_time = nil
        end

        def load_crud_data
          config = CrudConfig.instance.config
          return unless config.enabled

          unless File.exist?(config.crud_file_path)
            CrudLogger.logger.warn "CRUD file not found: #{config.crud_file_path}"
            return false
          end

          @workbook = RubyXL::Parser.parse(config.crud_file_path)
          @last_loaded_time = File.mtime(config.crud_file_path)
          sheet = crud_sheet
          headers = sheet[0].cells.map(&:value)

          method_col_index = headers.index(config.method_col)
          action_col_index = headers.index(config.action_col)
          table_start_col_index = headers.index(config.table_start_col)

          raise "Method column not found" unless method_col_index
          raise "Action column not found" unless action_col_index
          raise "Table start column not found" unless table_start_col_index

          headers[table_start_col_index..].each_with_index do |table_name, index|
            @crud_cols[table_name] = table_start_col_index + index
          end

          sheet.each_with_index do |row, index|
            next if index.zero?

            method = row[method_col_index]&.value.to_s.strip
            method = Constants::DEFAULT_METHOD if method.empty?
            value = row[action_col_index]&.value
            split_value = value&.split
            action = split_value&.first
            next if action.nil?

            @crud_rows[method] ||= {}
            @crud_rows[method][action] = index
          end
        end

        # CRUDデータが更新された場合に再読み込みする
        def reload_if_needed
          config = CrudConfig.instance.config
          return unless config.enabled

          return unless @last_loaded_time.nil? || File.mtime(config.crud_file_path) > @last_loaded_time

          last_modified_by = get_last_modified_by(config.crud_file_path)
          CrudLogger.logger.info "last modified by: #{last_modified_by}. process_id: #{process_id}"
          return if process_id == last_modified_by

          CrudLogger.logger.info "Reloading CRUD data due to file modification. last_loaded_time = #{@last_loaded_time}"
          load_crud_data
        end

        # xlsxファイルの最終更新者を取得する
        def get_last_modified_by(file_path)
          last_modified_by = nil

          Zip::File.open(file_path) do |zipfile|
            doc_props = zipfile.find_entry("docProps/core.xml")
            if doc_props
              content = doc_props.get_input_stream.read
              last_modified_by = content[%r{<cp:lastModifiedBy>(.*?)</cp:lastModifiedBy>}, 1]
            else
              CrudLogger.logger.warn "docProps/core.xml が見つかりませんでした。"
            end
          end

          last_modified_by
        end

        # CRUDシートを取得する
        def crud_sheet
          sheet_name = CrudConfig.instance.config.crud_file.sheet_name
          sheet = @workbook[sheet_name]
          raise "CRUD sheet '#{sheet_name}' not found" if sheet.nil?

          sheet
        end
      end
    end
  end
end
