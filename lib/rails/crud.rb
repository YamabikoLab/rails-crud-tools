require "rubyXL"
require "rubyXL/convenience_methods/cell"
require "rubyXL/convenience_methods/color"
require "rubyXL/convenience_methods/font"
require "rubyXL/convenience_methods/workbook"
require "rubyXL/convenience_methods/worksheet"
require_relative "crud_config"
require_relative "crud_notifications"
require_relative "railtie"

module Rails
  module Crud
    def self.load_crud_data
      CrudData.instance.load_crud_data
    end

    def self.generate_crud_file
      config = CrudConfig.instance

      routes_output = `bundle exec rails routes --expanded`
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

      table_names = ActiveRecord::Base.connection.tables.sort

      workbook = RubyXL::Workbook.new
      sheet = workbook[0]
      sheet.sheet_name = "Routes"

      headers = %w[Prefix Verb URI Controller#Action] + table_names

      headers.each_with_index do |header, index|
        cell = sheet.add_cell(0, index, header)
        cell.change_fill(config.header_bg_color)
        cell.change_font_bold(true)
        cell.change_border(:top, "thin")
        cell.change_border(:bottom, "thin")
        cell.change_border(:left, "thin")
        cell.change_border(:right, "thin")
      end

      headers.each_with_index do |header, index|
        sheet.change_column_width(index, header.length + 2)
      end

      routes_data.each_with_index do |route, row_index|
        headers.each_with_index do |header, col_index|
          cell = sheet.add_cell(row_index + 1, col_index, route[header])
          cell.change_border(:top, "thin")
          cell.change_border(:bottom, "thin")
          cell.change_border(:left, "thin")
          cell.change_border(:right, "thin")
        end
      end

      sheet.change_row_fill(0, config.header_bg_color)

      workbook.write(config.crud_file_path)

      puts "Output: #{config.crud_file_path}"
    end

    self.load_crud_data
    setup_notifications
  end
end