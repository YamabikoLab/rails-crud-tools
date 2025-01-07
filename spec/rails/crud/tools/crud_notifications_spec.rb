require "spec_helper"
require "rails/crud/tools/crud_notifications"
require "rails/crud/tools/crud_operations"
require "active_support/notifications"
require "active_support"
require "active_support/isolated_execution_state"

RSpec.describe Rails::Crud::Tools do
  describe ".setup_notifications" do

    it "logs SQL queries and adds operations" do
      described_class.setup_notifications

      # ダミーのリクエストオブジェクトを作成して設定
      request = double("request", request_method: "GET", params: { "controller" => "users", "action" => "index" })
      Thread.current[:crud_request] = request

      payload = { sql: "SELECT * FROM users", name: "SQL" }
      event = ActiveSupport::Notifications::Event.new("sql.active_record", Time.now, Time.now, 1, payload)

      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("GET", "users#index", "users", "R")

      ActiveSupport::Notifications.instrument("sql.active_record", payload) do
        ActiveSupport::Notifications.publish(event)
      end

    end

    it "logs SQL queries with JOIN and adds operations" do
      described_class.setup_notifications

      # ダミーのリクエストオブジェクトを作成して設定
      request = double("request", request_method: "GET", params: { "controller" => "users", "action" => "index" })
      Thread.current[:crud_request] = request

      # JOINを含むSQLクエリのテストケース
      join_payload = { sql: "SELECT users.*, orders.* FROM users INNER JOIN orders ON users.id = orders.user_id", name: "SQL" }
      join_event = ActiveSupport::Notifications::Event.new("sql.active_record", Time.now, Time.now, 1, join_payload)

      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("GET", "users#index", "users", "R")
      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("GET", "users#index", "orders", "R")

      ActiveSupport::Notifications.instrument("sql.active_record", join_payload) do
        ActiveSupport::Notifications.publish(join_event)
      end
    end

    it "logs SQL queries with comma-separated table names and adds operations" do
      described_class.setup_notifications

      # ダミーのリクエストオブジェクトを作成して設定
      request = double("request", request_method: "GET", params: { "controller" => "users", "action" => "index" })
      Thread.current[:crud_request] = request

      # カンマ区切りのテーブル名を含むSQLクエリのテストケース
      comma_payload = { sql: "SELECT * FROM users, orders WHERE users.id = orders.user_id", name: "SQL" }
      comma_event = ActiveSupport::Notifications::Event.new("sql.active_record", Time.now, Time.now, 1, comma_payload)

      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("GET", "users#index", "users", "R")
      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("GET", "users#index", "orders", "R")

      ActiveSupport::Notifications.instrument("sql.active_record", comma_payload) do
        ActiveSupport::Notifications.publish(comma_event)
      end
    end

    it "logs SQL queries with UNION, JOIN, and comma-separated table names and adds operations" do
      described_class.setup_notifications

      # ダミーのリクエストオブジェクトを作成して設定
      request = double("request", request_method: "GET", params: { "controller" => "users", "action" => "index" })
      Thread.current[:crud_request] = request

      # UNIONを含む複雑なSQLクエリのテストケース
      union_payload = { sql: "SELECT users.*, orders.* FROM users INNER JOIN orders ON users.id = orders.user_id UNION SELECT products.*, categories.* FROM products, categories WHERE products.category_id = categories.id", name: "SQL" }
      union_event = ActiveSupport::Notifications::Event.new("sql.active_record", Time.now, Time.now, 1, union_payload)

      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("GET", "users#index", "users", "R")
      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("GET", "users#index", "orders", "R")
      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("GET", "users#index", "products", "R")
      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("GET", "users#index", "categories", "R")

      ActiveSupport::Notifications.instrument("sql.active_record", union_payload) do
        ActiveSupport::Notifications.publish(union_event)
      end
    end

    it "logs SQL queries with newlines and adds operations" do
      described_class.setup_notifications

      # ダミーのリクエストオブジェクトを作成して設定
      request = double("request", request_method: "GET", params: { "controller" => "users", "action" => "index" })
      Thread.current[:crud_request] = request

      # 改行を含むSQLクエリのテストケース
      newline_payload = { sql: "SELECT users.*,\norders.*\nFROM users\nINNER JOIN orders ON users.id = orders.user_id", name: "SQL" }
      newline_event = ActiveSupport::Notifications::Event.new("sql.active_record", Time.now, Time.now, 1, newline_payload)

      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("GET", "users#index", "users", "R")
      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("GET", "users#index", "orders", "R")

      ActiveSupport::Notifications.instrument("sql.active_record", newline_payload) do
        ActiveSupport::Notifications.publish(newline_event)
      end
    end

    it "logs SQL queries and adds operations for INSERT and SELECT" do
      described_class.setup_notifications

      # ダミーのリクエストオブジェクトを作成して設定
      request = double("request", request_method: "POST", params: { "controller" => "users", "action" => "create" })
      Thread.current[:crud_request] = request

      insert_payload = { sql: "INSERT INTO users (name, email) VALUES ('Test User', 'test@example.com')", name: "SQL" }
      insert_event = ActiveSupport::Notifications::Event.new("sql.active_record", Time.now, Time.now, 1, insert_payload)

      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("POST", "users#create", "users", "C")

      ActiveSupport::Notifications.instrument("sql.active_record", insert_payload) do
        ActiveSupport::Notifications.publish(insert_event)
      end

      # Select操作のテストケース
      request = double("request", request_method: "GET", params: { "controller" => "users", "action" => "index" })
      Thread.current[:crud_request] = request

      select_payload = { sql: "SELECT * FROM users", name: "SQL" }
      select_event = ActiveSupport::Notifications::Event.new("sql.active_record", Time.now, Time.now, 1, select_payload)

      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("GET", "users#index", "users", "R")

      ActiveSupport::Notifications.instrument("sql.active_record", select_payload) do
        ActiveSupport::Notifications.publish(select_event)
      end
    end

    it "logs SQL queries for INSERT with the selected results using JOIN and adds operations" do
      described_class.setup_notifications

      # ダミーのリクエストオブジェクトを作成して設定
      request = double("request", request_method: "POST", params: { "controller" => "users", "action" => "create" })
      Thread.current[:crud_request] = request

      # INSERTクエリのテストケース
      insert_payload = { sql: "INSERT INTO archived_users (id, name, email) SELECT users.id, users.name, users.email FROM users INNER JOIN orders ON users.id = orders.user_id WHERE users.active = 1", name: "SQL" }
      insert_event = ActiveSupport::Notifications::Event.new("sql.active_record", Time.now, Time.now, 1, insert_payload)

      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("POST", "users#create", "archived_users", "C")
      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("POST", "users#create", "users", "R")
      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("POST", "users#create", "orders", "R")

      ActiveSupport::Notifications.instrument("sql.active_record", insert_payload) do
        ActiveSupport::Notifications.publish(insert_event)
      end
    end

    it "logs SQL queries for INSERT with the selected results using comma-separated SELECT and adds operations" do
      described_class.setup_notifications

      # ダミーのリクエストオブジェクトを作成して設定
      request = double("request", request_method: "POST", params: { "controller" => "users", "action" => "create" })
      Thread.current[:crud_request] = request

      # INSERTクエリのテストケース
      insert_payload = { sql: "INSERT INTO archived_users (id, name, email) SELECT users.id, users.name, users.email FROM users, orders WHERE users.id = orders.user_id AND users.active = 1", name: "SQL" }
      insert_event = ActiveSupport::Notifications::Event.new("sql.active_record", Time.now, Time.now, 1, insert_payload)

      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("POST", "users#create", "archived_users", "C")
      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("POST", "users#create", "users", "R")
      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("POST", "users#create", "orders", "R")

      ActiveSupport::Notifications.instrument("sql.active_record", insert_payload) do
        ActiveSupport::Notifications.publish(insert_event)
      end
    end

    it "logs SQL queries for UPDATE and adds operations" do
      described_class.setup_notifications

      # ダミーのリクエストオブジェクトを作成して設定
      request = double("request", request_method: "POST", params: { "controller" => "users", "action" => "update" })
      Thread.current[:crud_request] = request

      # UPDATEクエリのテストケース
      update_payload = { sql: "UPDATE users SET name = 'new_name' WHERE id = 1", name: "SQL" }
      update_event = ActiveSupport::Notifications::Event.new("sql.active_record", Time.now, Time.now, 1, update_payload)

      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("POST", "users#update", "users", "U")

      ActiveSupport::Notifications.instrument("sql.active_record", update_payload) do
        ActiveSupport::Notifications.publish(update_event)
      end
    end

    it "logs SQL queries for DELETE and adds operations" do
      described_class.setup_notifications

      # ダミーのリクエストオブジェクトを作成して設定
      request = double("request", request_method: "DELETE", params: { "controller" => "users", "action" => "destroy" })
      Thread.current[:crud_request] = request

      # DELETEクエリのテストケース
      delete_payload = { sql: "DELETE FROM users WHERE id = 1", name: "SQL" }
      delete_event = ActiveSupport::Notifications::Event.new("sql.active_record", Time.now, Time.now, 1, delete_payload)

      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("DELETE", "users#destroy", "users", "D")

      ActiveSupport::Notifications.instrument("sql.active_record", delete_payload) do
        ActiveSupport::Notifications.publish(delete_event)
      end
    end

    it "logs SQL queries for subqueries and adds operations" do
      described_class.setup_notifications

      # サブクエリのSELECTクエリのテストケース
      request = double("request", request_method: "GET", params: { "controller" => "users", "action" => "index" })
      Thread.current[:crud_request] = request

      select_payload = { sql: "SELECT * FROM users WHERE id IN (SELECT user_id FROM orders WHERE total > 100)", name: "SQL" }
      select_event = ActiveSupport::Notifications::Event.new("sql.active_record", Time.now, Time.now, 1, select_payload)

      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("GET", "users#index", "users", "R")
      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("GET", "users#index", "orders", "R")

      ActiveSupport::Notifications.instrument("sql.active_record", select_payload) do
        ActiveSupport::Notifications.publish(select_event)
      end
    end

    it "logs SQL queries for UPDATE with subqueries and adds operations" do
      described_class.setup_notifications

      # サブクエリのUPDATEクエリのテストケース
      request = double("request", request_method: "POST", params: { "controller" => "users", "action" => "update" })
      Thread.current[:crud_request] = request

      update_payload = { sql: "UPDATE users SET name = (SELECT name FROM archived_users WHERE users.id = archived_users.id)", name: "SQL" }
      update_event = ActiveSupport::Notifications::Event.new("sql.active_record", Time.now, Time.now, 1, update_payload)

      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("POST", "users#update", "users", "U")
      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("POST", "users#update", "archived_users", "R")

      ActiveSupport::Notifications.instrument("sql.active_record", update_payload) do
        ActiveSupport::Notifications.publish(update_event)
      end
    end

    it "logs SQL queries for DELETE with subqueries and adds operations" do
      described_class.setup_notifications

      # サブクエリのDELETEクエリのテストケース
      request = double("request", request_method: "DELETE", params: { "controller" => "users", "action" => "destroy" })
      Thread.current[:crud_request] = request

      delete_payload = { sql: "DELETE FROM users WHERE EXISTS (SELECT 1 FROM archived_users WHERE users.id = archived_users.id)", name: "SQL" }
      delete_event = ActiveSupport::Notifications::Event.new("sql.active_record", Time.now, Time.now, 1, delete_payload)

      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("DELETE", "users#destroy", "users", "D")
      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("DELETE", "users#destroy", "archived_users", "R")

      ActiveSupport::Notifications.instrument("sql.active_record", delete_payload) do
        ActiveSupport::Notifications.publish(delete_event)
      end
    end

    it "logs SQL queries for lowercase SQL statements and adds operations" do
      described_class.setup_notifications

      # 小文字のINSERTクエリのテストケース
      request = double("request", request_method: "POST", params: { "controller" => "users", "action" => "create" })
      Thread.current[:crud_request] = request

      insert_payload = { sql: "insert into archived_users (id, name, email) select users.id, users.name, users.email from users where users.active = 1", name: "SQL" }
      insert_event = ActiveSupport::Notifications::Event.new("sql.active_record", Time.now, Time.now, 1, insert_payload)

      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("POST", "users#create", "archived_users", "C")
      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("POST", "users#create", "users", "R")

      ActiveSupport::Notifications.instrument("sql.active_record", insert_payload) do
        ActiveSupport::Notifications.publish(insert_event)
      end

      # 小文字のUPDATEクエリのテストケース
      request = double("request", request_method: "POST", params: { "controller" => "users", "action" => "update" })
      Thread.current[:crud_request] = request

      update_payload = { sql: "update users set name = 'new_name' where id = 1", name: "SQL" }
      update_event = ActiveSupport::Notifications::Event.new("sql.active_record", Time.now, Time.now, 1, update_payload)

      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("POST", "users#update", "users", "U")

      ActiveSupport::Notifications.instrument("sql.active_record", update_payload) do
        ActiveSupport::Notifications.publish(update_event)
      end

      # 小文字のDELETEクエリのテストケース
      request = double("request", request_method: "POST", params: { "controller" => "users", "action" => "destroy" })
      Thread.current[:crud_request] = request

      delete_payload = { sql: "delete from users where id = 1", name: "SQL" }
      delete_event = ActiveSupport::Notifications::Event.new("sql.active_record", Time.now, Time.now, 1, delete_payload)

      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("POST", "users#destroy", "users", "D")

      ActiveSupport::Notifications.instrument("sql.active_record", delete_payload) do
        ActiveSupport::Notifications.publish(delete_event)
      end

      # 小文字のSELECTクエリのテストケース
      request = double("request", request_method: "POST", params: { "controller" => "users", "action" => "index" })
      Thread.current[:crud_request] = request

      select_payload = { sql: "select users.id, users.name, orders.total from users join orders on users.id = orders.user_id where users.active = 1", name: "SQL" }
      select_event = ActiveSupport::Notifications::Event.new("sql.active_record", Time.now, Time.now, 1, select_payload)

      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("POST", "users#index", "users", "R")
      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).to receive(:add_operation).with("POST", "users#index", "orders", "R")

      ActiveSupport::Notifications.instrument("sql.active_record", select_payload) do
        ActiveSupport::Notifications.publish(select_event)
      end
    end

    it "does not call add_operation for non-CRUD SQL queries" do
      described_class.setup_notifications

      # ダミーのリクエストオブジェクトを作成して設定
      request = double("request", request_method: "POST", params: { "controller" => "users", "action" => "create" })
      Thread.current[:crud_request] = request

      # 非CRUDクエリのテストケース
      non_crud_payload = { sql: "CREATE TABLE new_table (id INT, name VARCHAR(255))", name: "SQL" }
      non_crud_event = ActiveSupport::Notifications::Event.new("sql.active_record", Time.now, Time.now, 1, non_crud_payload)

      expect_any_instance_of(Rails::Crud::Tools::CrudOperations).not_to receive(:add_operation)

      ActiveSupport::Notifications.instrument("sql.active_record", non_crud_payload) do
        ActiveSupport::Notifications.publish(non_crud_event)
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
      result = described_class.send(:determine_key_and_method)
      expect(result).to be_nil
    end
  end
end