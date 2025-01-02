# frozen_string_literal: true

require 'fileutils'

def create_directories
  @doc_dir = File.join(Dir.pwd, 'doc')
  @log_dir = File.join(Dir.pwd, 'log')
  FileUtils.mkdir_p(@doc_dir)
  FileUtils.mkdir_p(@log_dir)
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    create_directories
  end

  config.after(:each) do
    FileUtils.remove_entry(@doc_dir) if @doc_dir && Dir.exist?(@doc_dir)
    FileUtils.remove_entry(@log_dir) if @log_dir && Dir.exist?(@log_dir)
  end

  create_directories

  require "rails/crud/tools"
end
