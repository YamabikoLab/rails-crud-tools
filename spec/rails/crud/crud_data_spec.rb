require_relative "../../spec_helper"
require "rails/crud/crud_data"
require "rails/crud/crud_config"
require "rails/crud/crud_logger"

RSpec.describe Rails::Crud::CrudData do
  let(:config) do
    instance_double("Rails::Crud::CrudConfig", enabled: true, crud_file_path: "spec/fixtures/test_crud.xlsx",
                                               method_col: "Method", action_col: "Action", table_start_col: "Table")
  end
  let(:crud_data) { described_class.instance }

  before do
    crud_data.instance_variable_set(:@config, config)
  end

  describe "#load_crud_data" do
    context "when config is disabled" do
      before { allow(config).to receive(:enabled).and_return(false) }

      it "does not load data" do
        expect(crud_data.load_crud_data).to be_nil
      end
    end

    context "when CRUD file does not exist" do
      before { allow(File).to receive(:exist?).with(config.crud_file_path).and_return(false) }

      it "logs a warning and returns false" do
        expect(crud_data.load_crud_data).to be false
      end
    end

    context "when CRUD file exists" do
      before do
        allow(File).to receive(:exist?).with(config.crud_file_path).and_return(true)
        allow(RubyXL::Parser).to receive(:parse).with(config.crud_file_path).and_return(RubyXL::Workbook.new)
        allow(File).to receive(:mtime).with(config.crud_file_path).and_return(Time.now)
      end

      it "loads and parses the workbook" do
        expect(crud_data).to receive(:parse_workbook)
        expect(crud_data).to receive(:parse_headers)
        expect(crud_data).to receive(:parse_rows)
        crud_data.load_crud_data
      end
    end
  end

  describe "#reload_if_needed" do
    context "when config is disabled" do
      before { allow(config).to receive(:enabled).and_return(false) }

      it "does not reload data" do
        expect(crud_data.reload_if_needed).to be_nil
      end
    end

    context "when file is modified" do
      before do
        allow(File).to receive(:mtime).with(config.crud_file_path).and_return(Time.now + 3600)
        crud_data.instance_variable_set(:@last_loaded_time, Time.now)
      end

      it "reloads the data" do
        expect(crud_data).to receive(:load_crud_data)
        crud_data.reload_if_needed
      end
    end
  end
end
