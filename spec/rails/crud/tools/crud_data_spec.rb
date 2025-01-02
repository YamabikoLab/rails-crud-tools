require_relative "../../../spec_helper"
require "rubyXL"
require "rubyXL/convenience_methods"
require "singleton"

RSpec.describe Rails::Crud::Tools::CrudData do
  let(:crud_data) { described_class.instance }
  let(:config) { instance_double("CrudConfig", enabled: true, crud_file_path: "spec/fixtures/test_crud.xlsx", method_col: "Method", action_col: "Action", table_start_col: "Table") }

  before do
    allow(CrudConfig).to receive(:instance).and_return(config)
    allow(File).to receive(:exist?).with(config.crud_file_path).and_return(true)
    allow(File).to receive(:mtime).with(config.crud_file_path).and_return(Time.now)
    allow(RubyXL::Parser).to receive(:parse).with(config.crud_file_path).and_return(workbook)
  end

  let(:workbook) do
    config = CrudConfig.instance
    workbook = RubyXL::Workbook.new
    sheet = workbook[0]
    sheet.add_cell(0, 0, config.method_col)
    sheet.add_cell(0, 1, config.action_col)
    sheet.add_cell(0, 2, config.table_start_col)
    sheet.add_cell(1, 0, "GET")
    sheet.add_cell(1, 1, "index")
    workbook
  end

  describe "#load_crud_data" do
    it "loads CRUD data from the file" do
      crud_data.load_crud_data

      expect(crud_data.crud_rows).to eq({ "GET" => { "index" => 1 } })
      expect(crud_data.crud_cols).to eq({ "Table" => 2 })
    end

    it "raises an error if method column is not found" do
      allow(config).to receive(:method_col).and_return("NonExistentColumn")
      expect { crud_data.load_crud_data }.to raise_error("Method column not found")
    end

    it "raises an error if action column is not found" do
      allow(config).to receive(:action_col).and_return("NonExistentColumn")
      expect { crud_data.load_crud_data }.to raise_error("Action column not found")
    end

    it "raises an error if table start column is not found" do
      allow(config).to receive(:table_start_col).and_return("NonExistentColumn")
      expect { crud_data.load_crud_data }.to raise_error("Table start column not found")
    end
  end

  describe "#reload_if_needed" do
    it "reloads CRUD data if the file has been modified" do
      crud_data.load_crud_data
      allow(File).to receive(:mtime).with(config.crud_file_path).and_return(Time.now + 3600)

      expect(crud_data).to receive(:load_crud_data)
      crud_data.reload_if_needed
    end

    it "does not reload CRUD data if the file has not been modified" do
      crud_data.load_crud_data
      allow(File).to receive(:mtime).with(config.crud_file_path).and_return(Time.now)

      expect(crud_data).not_to receive(:load_crud_data)
      crud_data.reload_if_needed
    end
  end
end