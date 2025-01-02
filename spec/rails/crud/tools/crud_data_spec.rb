require "spec_helper"
require "rubyXL"
require "rubyXL/convenience_methods"
require "singleton"
require "fileutils"

RSpec.describe Rails::Crud::Tools::CrudData do
  let(:crud_data) { described_class.instance }

  before do
    allow(File).to receive(:exist?).and_return(true)
    allow(File).to receive(:mtime).and_return(Time.now)
    allow(RubyXL::Parser).to receive(:parse).and_return(workbook)
  end

  let(:workbook) do
    workbook = RubyXL::Workbook.new
    sheet = workbook[0]
    sheet.sheet_name = Rails::Crud::Tools::CrudConfig.instance.sheet_name
    sheet.add_cell(0, 0, "Prefix")
    sheet.add_cell(0, 1, "Verb")
    sheet.add_cell(0, 2, "URI")
    sheet.add_cell(0, 3, "Controller#Action")
    sheet.add_cell(0, 4, "crud_count")
    sheet.add_cell(0, 5, "active_admin_comments")
    sheet.add_cell(0, 6, "active_storage_attachments")
    sheet.add_cell(0, 6, "active_storage_blobs")

    # 2行目のデータを追加
    sheet.add_cell(1, 0, "api_v1_users")
    sheet.add_cell(1, 1, "GET")
    sheet.add_cell(1, 2, "/api/v1/users")
    sheet.add_cell(1, 3, "users#index")
    sheet.add_cell(1, 4, 10)
    sheet.add_cell(1, 5, "No comments")
    sheet.add_cell(1, 6, "No attachments")

    # 3行目のデータを追加
    sheet.add_cell(2, 0, "api_v1_users")
    sheet.add_cell(2, 1, "POST")
    sheet.add_cell(2, 2, "/api/v1/users")
    sheet.add_cell(2, 3, "users#create")
    sheet.add_cell(2, 4, 5)
    sheet.add_cell(2, 5, "No comments")
    sheet.add_cell(2, 6, "No attachments")

    # 4行目のデータを追加
    sheet.add_cell(3, 0, "api_v1_users")
    sheet.add_cell(3, 1, "PUT")
    sheet.add_cell(3, 2, "/api/v1/users/:id")
    sheet.add_cell(3, 3, "users#update")
    sheet.add_cell(3, 4, 3)
    sheet.add_cell(3, 5, "No comments")
    sheet.add_cell(3, 6, "No attachments")

    # 5行目のデータを追加
    sheet.add_cell(4, 0, "api_v1_users")
    sheet.add_cell(4, 1, "DELETE")
    sheet.add_cell(4, 2, "/api/v1/users/:id")
    sheet.add_cell(4, 3, "users#destroy")
    sheet.add_cell(4, 4, 2)
    sheet.add_cell(4, 5, "No comments")
    sheet.add_cell(4, 6, "No attachments")

    workbook
  end

  describe "#load_crud_data" do
    it "loads CRUD data correctly" do
      crud_data.load_crud_data

      expect(crud_data.crud_rows).to eq({
                                          "GET" => { "users#index" => 1 },
                                          "POST" => { "users#create" => 2 },
                                          "PUT" => { "users#update" => 3 },
                                          "DELETE" => { "users#destroy" => 4 }
                                        })
      expect(crud_data.crud_cols).to eq({
                                          "active_admin_comments" => 5,
                                          "active_storage_blobs" => 6
                                        })
    end

    it "raises an error if method column is not found" do
      allow(Rails::Crud::Tools::CrudConfig.instance).to receive(:method_col).and_return("NonExistentColumn")
      expect { crud_data.load_crud_data }.to raise_error("Method column not found")
    end

    it "raises an error if action column is not found" do
      allow(Rails::Crud::Tools::CrudConfig.instance).to receive(:action_col).and_return("NonExistentColumn")
      expect { crud_data.load_crud_data }.to raise_error("Action column not found")
    end

    it "raises an error if table start column is not found" do
      allow(Rails::Crud::Tools::CrudConfig.instance).to receive(:table_start_col).and_return("NonExistentColumn")
      expect { crud_data.load_crud_data }.to raise_error("Table start column not found")
    end
  end

  describe "#reload_if_needed" do
    it "reloads CRUD data if the file has been modified" do
      crud_data.load_crud_data
      allow(File).to receive(:mtime).and_return(Time.now + 3600)

      expect(crud_data).to receive(:load_crud_data)
      crud_data.reload_if_needed
    end

    it "does not reload CRUD data if the file has not been modified" do
      crud_data.load_crud_data
      # ファイルのタイムスタンプを取得
      file_mtime = File.mtime(Rails::Crud::Tools::CrudConfig.instance.crud_file_path)

      # ファイルのタイムスタンプよりも1秒前の日時を設定
      allow(File).to receive(:mtime).and_return(file_mtime - 1)

      expect(crud_data).not_to receive(:load_crud_data)
      crud_data.reload_if_needed
    end
  end
end