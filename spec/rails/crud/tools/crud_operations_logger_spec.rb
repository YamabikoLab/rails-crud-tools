require "spec_helper"
require "ostruct"
require "rubyXL"
require "rubyXL/convenience_methods"

RSpec.describe Rails::Crud::Tools::OperationsLogger do
  let(:dummy_class) do
    Class.new do
      include Rails::Crud::Tools::OperationsLogger

      def request
        OpenStruct.new(request_method: "GET")
      end

      def controller_path
        "dummy_controller"
      end

      def action_name
        "dummy_action"
      end

      def self.name
        "DummyJob"
      end
    end
  end

  let(:instance) { dummy_class.new }

  before do
    allow(Rails::Crud::Tools::CrudOperations).to receive_message_chain(:instance, :table_operations_present?).and_return(true)
    allow(Rails::Crud::Tools::CrudOperations).to receive_message_chain(:instance, :log_operations)
    allow(Rails::Crud::Tools::CrudData).to receive_message_chain(:instance, :reload_if_needed)

    # RubyXLを使用してworkbookとsheetを作成
    workbook = RubyXL::Workbook.new
    sheet = workbook[0]

    # 必要なセルを追加し、値を設定
    sheet.add_cell(1, 1, "CRU")

    # workbookをモックとして設定
    allow(Rails::Crud::Tools::CrudData).to receive_message_chain(:instance, :workbook).and_return(workbook)
    allow(Rails::Crud::Tools::CrudData).to receive_message_chain(:instance, :crud_rows).and_return({ "GET" => { "dummy_controller#dummy_action" => 1 } })
    allow(Rails::Crud::Tools::CrudData).to receive_message_chain(:instance, :crud_cols).and_return({ "dummy_table" => 1 })
    allow(Rails::Crud::Tools::CrudOperations).to receive_message_chain(:instance, :table_operations).and_return({ "GET" => { "dummy_controller#dummy_action" => { "dummy_table" => ["C"] } } })
  end

  describe "#log_crud_operations" do
    it "executes the block and logs operations" do
      expect { |b| instance.log_crud_operations(&b) }.to yield_control
    end
  end

  describe "#log_crud_operations_for_job" do
    it "executes the block and logs operations for job" do
      expect { |b| instance.log_crud_operations_for_job(&b) }.to yield_control
    end
  end
end