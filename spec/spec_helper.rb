# frozen_string_literal: true

require 'rails/crud'
require 'active_record'
require 'sqlite3'
require 'active_support'
require 'active_support/notifications'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

ActiveRecord::Schema.define do
  create_table :your_table_name, force: true do |t|
    t.string :column_name
    t.timestamps
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
