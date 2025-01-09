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
    workbook
  end

  describe "#load_crud_data" do
    it "loads CRUD data correctly" do
      crud_data.load_crud_data

      expect(crud_data.crud_rows).to eq({
                                          "GET" => { "users#index" => 1 },
                                          "POST" => { "users#create" => 2 },
                                          "PUT" => { "users#update" => 3 },
                                          "DELETE" => { "users#destroy" => 4 },
                                          "default_method" => {"DummyJob"=>5}
                                        })
      expect(crud_data.crud_cols).to eq({
                                          "active_admin_comments" => 5,
                                          "active_storage_attachments" => 6,
                                          "active_storage_blobs" => 7
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

  describe "#get_crud_sheet" do

    before do
      crud_data.workbook = workbook
    end

    it "returns the sheet if found" do
      expect(crud_data.crud_sheet).not_to be_nil
    end

    it "raises an error if the sheet is not found" do
      non_existent_sheet_name = "NonExistentSheetName"
      allow(Rails::Crud::Tools::CrudConfig.instance).to receive(:sheet_name).and_return(non_existent_sheet_name)
      expect { crud_data.crud_sheet }.to raise_error("CRUD sheet '#{non_existent_sheet_name}' not found")
    end
  end
end