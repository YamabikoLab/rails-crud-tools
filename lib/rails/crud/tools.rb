# frozen_string_literal: true

require "rubyXL"
require "rubyXL/convenience_methods/cell"
require "rubyXL/convenience_methods/color"
require "rubyXL/convenience_methods/font"
require "rubyXL/convenience_methods/workbook"
require "rubyXL/convenience_methods/worksheet"
require_relative "tools/crud_operations"
require_relative "tools/crud_config"
require_relative "tools/crud_notifications"
require_relative "tools/railtie"
require_relative "tools/crud_data"

module Rails
  module Crud
    # The Tools module provides utility methods for setting up notifications and processing SQL queries.
    # It includes methods to subscribe to ActiveSupport notifications and handle different types of SQL operations.
    module Tools
      def self.setup
        unless File.exist?(CrudConfig.instance.config_file)
          puts "The .crudconfig.yml file is required. Please run `bundle exec crud init`."
          return
        end

        unless File.exist?(CrudConfig.instance.crud_file_path)
          puts "The CRUD file is required. Please run `bundle exec crud gen crud`."
          return
        end

        CrudData.instance.process_id = "rails-crud-tools-#{Time.now.strftime("%Y%m%d%H%M%S")}"
        CrudData.instance.load_crud_data
        setup_notifications
      end

      setup unless ENV["SKIP_CRUD_SETUP"] == "true"
    end
  end
end
