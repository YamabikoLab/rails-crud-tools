# frozen_string_literal: true

require 'fileutils'
def create_directories
  @doc_dir = File.join(Dir.pwd, 'doc')
  @log_dir = File.join(Dir.pwd, 'log')
  FileUtils.mkdir_p(@doc_dir)
  FileUtils.mkdir_p(@log_dir)
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    create_directories
  end

  config.after(:each) do
    FileUtils.remove_entry(@doc_dir) if @doc_dir && Dir.exist?(@doc_dir)
    FileUtils.remove_entry(@log_dir) if @log_dir && Dir.exist?(@log_dir)
  end

  create_directories

  require "rails/crud/tools"

  def workbook
    workbook = RubyXL::Workbook.new
    sheet = workbook[0]
    sheet.sheet_name = Rails::Crud::Tools::CrudConfig.instance.sheet_name
    # ヘッダー行
    sheet.add_cell(0, 0, "Prefix")
    sheet.add_cell(0, 1, "Verb")
    sheet.add_cell(0, 2, "URI")
    sheet.add_cell(0, 3, "Controller#Action")
    sheet.add_cell(0, 4, "crud_count")
    sheet.add_cell(0, 5, "active_admin_comments")
    sheet.add_cell(0, 6, "active_storage_attachments")
    sheet.add_cell(0, 7, "active_storage_blobs")

    # 2行目のデータを追加
    sheet.add_cell(1, 0, "api_v1_users")
    sheet.add_cell(1, 1, "GET")
    sheet.add_cell(1, 2, "/api/v1/users")
    sheet.add_cell(1, 3, "users#index")
    sheet.add_cell(1, 5, "R")
    sheet.add_cell(1, 6, "R")
    sheet.add_cell(1, 7, "")
    sheet.add_cell(1, 4, calculate_crud_count(sheet, 1))

    # 3行目のデータを追加
    sheet.add_cell(2, 0, "")
    sheet.add_cell(2, 1, "POST")
    sheet.add_cell(2, 2, "/api/v1/users")
    sheet.add_cell(2, 3, "users#create")
    sheet.add_cell(2, 5, "C")
    sheet.add_cell(2, 6, "RU")
    sheet.add_cell(2, 7, "")
    sheet.add_cell(2, 4, calculate_crud_count(sheet, 2))

    # 4行目のデータを追加
    sheet.add_cell(3, 0, "")
    sheet.add_cell(3, 1, "PUT")
    sheet.add_cell(3, 2, "/api/v1/users/:id")
    sheet.add_cell(3, 3, "users#update")
    sheet.add_cell(3, 5, "U")
    sheet.add_cell(3, 6, "CR")
    sheet.add_cell(3, 7, "")
    sheet.add_cell(3, 4, calculate_crud_count(sheet, 3))

    # 5行目のデータを追加
    sheet.add_cell(4, 0, "")
    sheet.add_cell(4, 1, "DELETE")
    sheet.add_cell(4, 2, "/api/v1/users/:id")
    sheet.add_cell(4, 3, "users#destroy")
    sheet.add_cell(4, 5, "D")
    sheet.add_cell(4, 6, "CU")
    sheet.add_cell(4, 7, "R")
    sheet.add_cell(4, 4, calculate_crud_count(sheet, 4))

    # ジョブのデータを追加
    sheet.add_cell(5, 0, "")
    sheet.add_cell(5, 1, "")
    sheet.add_cell(5, 2, "")
    sheet.add_cell(5, 3, "DummyJob")
    sheet.add_cell(5, 5, "C")
    sheet.add_cell(5, 6, "R")
    sheet.add_cell(5, 7, "U")
    sheet.add_cell(5, 4, calculate_crud_count(sheet, 5))

    workbook
  end

  private

  def calculate_crud_count(sheet, row)
    sheet[row][5].value.length + sheet[row][6].value.length + sheet[row][7].value.length
  end
end
