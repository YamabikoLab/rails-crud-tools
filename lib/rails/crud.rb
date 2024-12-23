require "rubyXL"
require "rubyXL/convenience_methods/cell"
require "rubyXL/convenience_methods/color"
require "rubyXL/convenience_methods/font"
require "rubyXL/convenience_methods/workbook"
require "rubyXL/convenience_methods/worksheet"
require_relative "crud_config"

module Rails
  module Crud
    # グローバル変数の定義
    $crud_rows = {}
    $crud_cols = {}

    def self.load_crud_data
      $crud_config = CrudConfig.new(".crudconfig")
      return unless $crud_config.enabled

      unless File.exist?($crud_config.crud_file_path)
        raise "CRUD file not found: #{$crud_config.crud_file_path}"
      end

      $workbook = RubyXL::Parser.parse($crud_config.crud_file_path)
      sheet = $workbook[0]
      headers = sheet[0].cells.map(&:value)

      method_col_index = headers.index($crud_config.method_col)
      action_col_index = headers.index($crud_config.action_col)
      table_start_col_index = headers.index($crud_config.table_start_col)

      raise "Method column not found" unless method_col_index
      raise "Action column not found" unless action_col_index
      raise "Table start column not found" unless table_start_col_index

      # テーブル名と列番号のマッピングを作成
      headers[table_start_col_index..-1].each_with_index do |table_name, index|
        $crud_cols[table_name] = table_start_col_index + index
      end

      # 行番号のマッピングを作成
      sheet.each_with_index do |row, index|
        next if index == 0 # ヘッダ行をスキップ

        method = row[method_col_index]&.value
        action = row[action_col_index]&.value
        next unless method && action

        $crud_rows[method] ||= {}
        $crud_rows[method][action] = index
      end
    end

    def self.generate_crud_file
      $crud_config = CrudConfig.new(".crudconfig")

      # 1. `bundle exec rails routes --expanded`の結果を取得
      routes_output = `bundle exec rails routes --expanded`

      # 2. 取得した結果を区切り文字で分割
      routes_lines = routes_output.split("\n").reject(&:empty?)
      routes_data = []
      current_route = {}

      routes_lines.each do |line|
        if line.start_with?("--[ Route")
          routes_data << current_route unless current_route.empty?
          current_route = {}
        else
          key, value = line.split("|").map(&:strip)
          current_route[key] = value
        end
      end
      routes_data << current_route unless current_route.empty?

      # 3. 全テーブル名を取得し、アルファベット順にソート
      table_names = ActiveRecord::Base.connection.tables.sort

      # 4. `rubyXL`を使って`xlsx`ファイルに書き込み
      $workbook = RubyXL::workbook.new
      sheet = $workbook[0]
      sheet.sheet_name = "Routes"

      # ヘッダー行を追加
      headers = %w[Prefix Verb URI Controller#Action] + table_names

      headers.each_with_index do |header, index|
        cell = sheet.add_cell(0, index, header)
        cell.change_fill($crud_config.header_bg_color)
        cell.change_font_bold(true)
        cell.change_border(:top, "thin")
        cell.change_border(:bottom, "thin")
        cell.change_border(:left, "thin")
        cell.change_border(:right, "thin")
      end

      headers.each_with_index do |header, index|
        sheet.change_column_width(index, header.length + 2)
      end

      # データ行を追加
      routes_data.each_with_index do |route, row_index|
        headers.each_with_index do |header, col_index|
          cell = sheet.add_cell(row_index + 1, col_index, route[header])
          cell.change_border(:top, "thin")
          cell.change_border(:bottom, "thin")
          cell.change_border(:left, "thin")
          cell.change_border(:right, "thin")
        end
      end

      # 行全体の背景色を設定
      sheet.change_row_fill(0, $crud_config.header_bg_color)

      # ファイルを保存
      $workbook.write($crud_config.crud_file_path)

      puts "Output: #{$crud_config.crud_file_path}"
    end

    # 初期化処理
    self.load_crud_data
  end
end