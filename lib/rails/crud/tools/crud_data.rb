require_relative "crud_logger"
require_relative "constants"

module Rails
  module Crud
    module Tools
      # このクラスは、CRUDファイルからデータを読み込むためのクラスです。
      class CrudData
        include Singleton

        attr_accessor :crud_rows, :crud_cols, :workbook

        def initialize
          @crud_rows = {}
          @crud_cols = {}
          @last_loaded_time = nil
        end

        def load_crud_data
          config = CrudConfig.instance
          return unless config.enabled

          unless File.exist?(config.crud_file_path)
            CrudLogger.logger.warn "CRUD file not found: #{config.crud_file_path}"
            return false
          end

          @workbook = RubyXL::Parser.parse(config.crud_file_path)
          @last_loaded_time = File.mtime(config.crud_file_path)
          sheet = @workbook[Rails::Crud::Tools::CrudConfig.instance.sheet_name]
          headers = sheet[0].cells.map(&:value)

          method_col_index = column_letter_to_index(config.method_col)
          action_col_index = column_letter_to_index(config.action_col)
          table_start_col_index = column_letter_to_index(config.table_start_col)

          raise "Method column not found" unless method_col_index
          raise "Action column not found" unless action_col_index
          raise "Table start column not found" unless table_start_col_index

          headers[table_start_col_index..-1].each_with_index do |table_name, index|
            @crud_cols[table_name] = table_start_col_index + index
          end

          sheet.each_with_index do |row, index|
            next if index == 0

            method = row[method_col_index]&.value.to_s.strip
            method = Constants::DEFAULT_METHOD if method.empty?
            action = row[action_col_index]&.value&.split&.first
            next if action.nil?

            @crud_rows[method] ||= {}
            @crud_rows[method][action] = index
          end
        end

        # CRUDデータが更新された場合に再読み込みする
        def reload_if_needed
          config = CrudConfig.instance
          return unless config.enabled

          if @last_loaded_time.nil? || File.mtime(config.crud_file_path) > @last_loaded_time
            CrudLogger.logger.info "Reloading CRUD data due to file modification. last_loaded_time = #{@last_loaded_time}"
            load_crud_data
          end
        end

        private

        # アルファベットをインデックスに変換するヘルパーメソッド
        def column_letter_to_index(letter)
          return nil unless letter.is_a?(String) && letter.length == 1 && letter =~ /^[A-Z]$/i

          letter.upcase.ord - "A".ord
        end
      end
    end
  end
end