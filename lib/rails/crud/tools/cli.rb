require "rubyXL"
require 'rubyXL/convenience_methods'
require 'active_record'
require 'yaml'
require 'erb'

module RailsCrudTools
  class CLI
    @application_loaded = false
    class << self
      def generate_crud_file
        load_application unless @application_loaded

        # 1. `bundle exec rails routes --expanded`の結果を取得
        routes_output = `bundle exec rails routes --expanded`
        config = Rails::Crud::Tools::CrudConfig.instance
        font_name = config.font_name

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
        workbook = RubyXL::Workbook.new
        sheet = workbook[0]
        sheet.sheet_name = config.sheet_name

        # ヘッダー行を追加
        headers = %w[Prefix Verb URI Controller#Action crud_count] + table_names

        headers.each_with_index do |header, index|
          cell = sheet.add_cell(0, index, header)
          cell.change_fill("00FFCC")
          cell.change_font_name(font_name)
          cell.change_font_bold(true)
          apply_borders(cell)
        end

        start_col = "F"
        end_col = ("A".."ZZ").to_a[table_names.length + 4] # 'F'から始まる列の範囲を計算

        # データ行を追加
        routes_data.each_with_index do |route, row_index|
          headers.each_with_index do |header, col_index|
            cell = sheet.add_cell(row_index + 1, col_index, route[header])
            cell.change_font_name(font_name)
            apply_borders(cell)
          end

          # 追加: crud_count列に式を設定
          crud_count_formula = "=SUMPRODUCT(LEN(#{start_col}#{row_index + 2}:#{end_col}#{row_index + 2}))"
          crud_count_cell = sheet.add_cell(row_index + 1, 4, "", crud_count_formula)
          crud_count_cell.change_font_name(font_name)
          apply_borders(crud_count_cell)
        end

        # app/jobs ディレクトリ内のジョブ名を取得
        job_files = Dir.glob("app/jobs/**/*.rb")
        job_classes = job_files.map do |file|
          File.basename(file, ".rb").camelize
        end.reject { |job| job == "ApplicationJob" }.sort

        # ジョブ名を Controller#Action 列に追加
        job_classes.each_with_index do |job, index|
          headers.each_with_index do |header, col_index|
            if header == "Controller#Action"
              cell = sheet.add_cell(routes_data.length + 1 + index, col_index, job)
              cell.change_font_name(font_name)
            else
              cell = sheet.add_cell(routes_data.length + 1 + index, col_index, nil)
            end
            apply_borders(cell)
          end

          # 追加: crud_count列に式を設定
          crud_count_formula = "=SUMPRODUCT(LEN(#{start_col}#{routes_data.length + 2 + index}:#{end_col}#{routes_data.length + 2 + index}))"
          crud_count_cell = sheet.add_cell(routes_data.length + 1 + index, 4, "", crud_count_formula)
          crud_count_cell.change_font_name(font_name)
          apply_borders(crud_count_cell)
        end

        # ヘッダーの背景色を設定
        (0..headers.length - 1).each do |col_index|
          sheet[0][col_index].change_fill(config.header_bg_color)
        end

        # 列幅を設定
        headers.each_with_index do |header, col_index|
          max_length = header.length
          (1..routes_data.length).each do |row_index|
            cell_value = sheet[row_index][col_index].value.to_s
            max_length = [max_length, cell_value.length].max
          end
          sheet.change_column_width(col_index, max_length + 2)
        end

        # ファイルを保存
        crud_file = config.crud_file_path
        workbook.write(crud_file)

        puts "Output: #{crud_file}"
      end

      def generate_crudconfig
        load_application unless @application_loaded

        table_names = ActiveRecord::Base.connection.tables.sort
        table_start_col = table_names.any? ? table_names.first : "active_admin_comments"

        config_content = <<~CONFIG
          enabled: true
          base_dir: doc
          crud_file: crud.xlsx
          sheet_name: CRUD
          method_col: Verb
          action_col: Controller#Action
          table_start_col: #{table_start_col}
          sql_logging_enabled: true
          header_bg_color: 00FFCC
          font_name: Arial
        CONFIG

        File.write('.crudconfig', config_content)
        puts "Generated .crudconfig file"
      end

      def init
        generate_crudconfig
        generate_crud_file
      end

      private

      def load_application
        return if @application_loaded

        path = Dir.pwd
        $stderr.puts "Loading application in '#{File.basename(path)}'..."
        environment_path = "#{path}/config/environment.rb"
        require environment_path

        if defined? Rails
          Rails.application.eager_load!
          Rails.application.config.eager_load_namespaces.each(&:eager_load!) if Rails.application.config.respond_to?(:eager_load_namespaces)
        end

        @application_loaded = true
      rescue ::LoadError
        error_message = <<~EOS
          Tried to load your application environment from '#{environment_path}'.
        EOS
        puts error_message
      rescue TypeError
      end

      def apply_borders(cell)
        %i[top bottom left right].each do |side|
          cell.change_border(side, "thin")
        end
      end
    end
  end
end
