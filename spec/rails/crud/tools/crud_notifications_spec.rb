require "spec_helper"
require "rails/crud/tools/crud_notifications"
require "rails/crud/tools/crud_operations"
require "active_support/notifications"
require "active_support"
require "active_support/isolated_execution_state"

RSpec.describe Rails::Crud::Tools do
  describe ".setup_notifications" do
    before do
      allow(Rails::Crud::Tools::CrudLogger.logger).to receive(:info)
      allow(Rails::Crud::Tools::CrudLogger.logger).to receive(:warn)
    end

    it "logs SQL queries and adds operations" do
      described_class.setup_notifications

      # ダミーのリクエストオブジェクトを作成して設定
      request = double("request", request_method: "GET", params: { "controller" => "users", "action" => "index" })
      Thread.current[:crud_request] = request

      payload = { sql: "SELECT * FROM users", name: "SQL" }
      event = ActiveSupport::Notifications::Event.new("sql.active_record", Time.now, Time.now, 1, payload)

      expect(Rails::Crud::Tools::CrudLogger.logger).to receive(:info).with("SQL - SELECT * FROM users")
      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("GET", "users#index", "users", "R")

      ActiveSupport::Notifications.instrument("sql.active_record", payload) do
        ActiveSupport::Notifications.publish(event)
      end

    end

    it "logs SQL queries and adds operations for INSERT and SELECT" do
      described_class.setup_notifications

      # ダミーのリクエストオブジェクトを作成して設定
      request = double("request", request_method: "POST", params: { "controller" => "users", "action" => "create" })
      Thread.current[:crud_request] = request

      insert_payload = { sql: "INSERT INTO users (name, email) VALUES ('Test User', 'test@example.com')", name: "SQL" }
      insert_event = ActiveSupport::Notifications::Event.new("sql.active_record", Time.now, Time.now, 1, insert_payload)

      expect(Rails::Crud::Tools::CrudLogger.logger).to receive(:info).with("SQL - INSERT INTO users (name, email) VALUES ('Test User', 'test@example.com')")
      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("POST", "users#create", "users", "C")

      ActiveSupport::Notifications.instrument("sql.active_record", insert_payload) do
        ActiveSupport::Notifications.publish(insert_event)
      end

      # Select操作のテストケース
      request = double("request", request_method: "GET", params: { "controller" => "users", "action" => "index" })
      Thread.current[:crud_request] = request

      select_payload = { sql: "SELECT * FROM users", name: "SQL" }
      select_event = ActiveSupport::Notifications::Event.new("sql.active_record", Time.now, Time.now, 1, select_payload)

      expect(Rails::Crud::Tools::CrudLogger.logger).to receive(:info).with("SQL - SELECT * FROM users")
      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("GET", "users#index", "users", "R")

      ActiveSupport::Notifications.instrument("sql.active_record", select_payload) do
        ActiveSupport::Notifications.publish(select_event)
      end
    end

    it "warns when table name is not found in SQL" do
      described_class.setup_notifications

      payload = { sql: "SELECT * FROM", name: "SQL" }
      expect(Rails::Crud::Tools::CrudLogger.logger).to receive(:warn).with("Table name not found in SQL: SELECT * FROM")

      ActiveSupport::Notifications.instrument("sql.active_record", payload)
    end
  end

  describe "#determine_key_and_method" do
    before do
      Thread.current[:crud_request] = nil
      Thread.current[:crud_sidekiq_job_class] = nil
    end

    it "returns key and method from request" do
      request = double("request", request_method: "GET", params: { "controller" => "users", "action" => "index" })
      Thread.current[:crud_request] = request

      key, method = described_class.send(:determine_key_and_method)
      expect(key).to eq("users#index")
      expect(method).to eq("GET")
    end

    it "returns key and default method from sidekiq job class" do
      Thread.current[:crud_sidekiq_job_class] = "SomeJobClass"

      key, method = described_class.send(:determine_key_and_method)
      expect(key).to eq("SomeJobClass")
      expect(method).to eq(Rails::Crud::Tools::Constants::DEFAULT_METHOD)
    end

    it "returns nil and logs a warning when neither request nor sidekiq job class is present" do
      expect(Rails::Crud::Tools::CrudLogger.logger).to receive(:warn).with("Unknown method and key detected")

      result = described_class.send(:determine_key_and_method)
      expect(result).to be_nil
    end
  end
end