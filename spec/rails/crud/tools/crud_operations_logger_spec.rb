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
        OpenStruct.new(request_method: "PUT")
      end

      def controller_path
        "users"
      end

      def action_name
        "update"
      end

      def self.name
        "DummyJob"
      end
    end
  end

  let(:instance) { dummy_class.new }

  before do
    allow(File).to receive(:exist?).and_return(true)
    allow(Rails::Crud::Tools::CrudOperations).to receive_message_chain(:instance, :table_operations_present?).and_return(true)
    allow(Rails::Crud::Tools::CrudOperations).to receive_message_chain(:instance, :log_operations)

    workbook
    Rails::Crud::Tools::CrudData.instance.load_crud_data
  end

  describe "#log_crud_operations" do
    before do
      allow(Rails::Crud::Tools::CrudOperations).to receive_message_chain(:instance, :table_operations).and_return({ "PUT" => { "users#update" => { "active_admin_comments" => ["C"] } } })
    end

    it "executes the block and logs operations" do
      # 1.ブロックを実行し、データ更新が正しく行われているかを確認
      expect { |b| instance.log_crud_operations(&b) }.to yield_control

      # 2. crud_fileを読み込み、データが更新されているか確認
      workbook = RubyXL::Parser.parse(Rails::Crud::Tools::CrudConfig.instance.crud_file_path)
      sheet = workbook[0]
      cell = sheet[3][5]

      # 3. cellの値が"CU"であることを確認
      expect(cell.value).to eq("CU")
    end
  end

  it "does not write to the Excel file if contents have not changed" do
    allow(Rails::Crud::Tools::CrudOperations).to receive_message_chain(:instance, :table_operations).and_return({ "PUT" => { "users#update" => { "active_admin_comments" => ["U"] } } })

    last_loaded_time_before = Rails::Crud::Tools::CrudData.instance.last_loaded_time

    instance.log_crud_operations {}

    last_loaded_time_after = Rails::Crud::Tools::CrudData.instance.last_loaded_time

    expect(last_loaded_time_after).to eq(last_loaded_time_before)
  end

  describe "#log_crud_operations_for_job" do
    before do
      allow(Rails::Crud::Tools::CrudOperations).to receive_message_chain(:instance, :table_operations).and_return({ Rails::Crud::Tools::Constants::DEFAULT_METHOD => { "DummyJob" => { "active_storage_blobs" => ["C"] } } })
    end

    it "executes the block and logs operations for job" do
      # 1.ブロックを実行し、データ更新が正しく行われているかを確認
      expect { |b| instance.log_crud_operations_for_job(&b) }.to yield_control

      # 2. crud_fileを読み込み、データが更新されているか確認
      workbook = RubyXL::Parser.parse(Rails::Crud::Tools::CrudConfig.instance.crud_file_path)
      sheet = workbook[0]
      cell = sheet[5][7]

      # 3. cellの値が"CU"であることを確認
      expect(cell.value).to eq("CU")
    end
  end
end