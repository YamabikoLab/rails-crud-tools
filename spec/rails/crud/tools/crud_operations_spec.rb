require "spec_helper"
require "rails/crud/tools/crud_operations"

RSpec.describe Rails::Crud::Tools::CrudOperations do
  let(:crud_operations) { described_class.instance }

  describe "#add_operation" do
    it "adds an operation to the table_operations hash" do
      method = "POST"
      key = "users#create"
      table_name = "users"
      operation = "C"

      crud_operations.add_operation(method, key, table_name, operation)

      expect(crud_operations.table_operations[method][key][table_name]).to include(operation)
    end
  end

  describe "#table_operations_present?" do
    it "returns true if operations are present for a given method and key" do
      method = "POST"
      key = "users#create"
      table_name = "users"
      operation = "C"

      crud_operations.add_operation(method, key, table_name, operation)

      expect(crud_operations.table_operations_present?(method, key)).to be true
    end

    it "returns false if no operations are present for a given method and key" do
      expect(crud_operations.table_operations_present?("GET", "users#index")).to be false
    end
  end
end