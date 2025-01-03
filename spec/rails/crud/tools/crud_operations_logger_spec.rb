require "spec_helper"
require "ostruct"
require "rubyXL"
require "rubyXL/convenience_methods"
require "rails/crud/tools/constants"

RSpec.describe Rails::Crud::Tools::OperationsLogger do
  let(:dummy_class) do
    Class.new do
      include Rails::Crud::Tools::OperationsLogger

      def request
        OpenStruct.new(request_method: "GET")
      end

      def controller_path
        "users"
      end

      def action_name
        "index"
      end

      def self.name
        "DummyJob"
      end
    end
  end

  let(:instance) { dummy_class.new }

  before do
    allow(File).to receive(:exist?).and_return(true)
    allow(File).to receive(:mtime).and_return(Time.now)
    allow(RubyXL::Parser).to receive(:parse).and_return(workbook)
    allow(Rails::Crud::Tools::CrudOperations).to receive_message_chain(:instance, :table_operations_present?).and_return(true)
    allow(Rails::Crud::Tools::CrudOperations).to receive_message_chain(:instance, :log_operations)

    Rails::Crud::Tools::CrudData.instance.load_crud_data
  end

  describe "#log_crud_operations" do
    before do
      allow(Rails::Crud::Tools::CrudOperations).to receive_message_chain(:instance, :table_operations).and_return({ "GET" => { "users#index" => { "active_admin_comments" => ["C"] } } })
    end

    it "executes the block and logs operations" do
      expect { |b| instance.log_crud_operations(&b) }.to yield_control
    end
  end

  describe "#log_crud_operations_for_job" do
    before do
      allow(Rails::Crud::Tools::CrudOperations).to receive_message_chain(:instance, :table_operations).and_return({ Rails::Crud::Tools::Constants::DEFAULT_METHOD => { "DummyJob" => { "active_storage_blobs" => ["C"] } } })
    end

    it "executes the block and logs operations for job" do
      expect { |b| instance.log_crud_operations_for_job(&b) }.to yield_control
    end
  end
end