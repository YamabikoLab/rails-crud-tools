require "yaml"

module Rails
  module Crud
    module Tools
      class CrudConfig
        include Singleton

        attr_accessor :enabled, :base_dir, :crud_file, :sheet_name, :method_col, :action_col, :table_start_col, :sql_logging_enabled, :header_bg_color, :font_name

        def initialize
          @config_file = ".crudconfig"
          @last_loaded = nil
          load_config
        end

        def load_config
          if @last_loaded.nil? || File.mtime(@config_file) > @last_loaded
            unless File.exist?(@config_file)
              raise "Config file not found: #{@config_file}. Please generate it using `bundle exec crud gen_config`."
            end

            config = YAML.load_file(@config_file)

            @enabled = config["enabled"]
            @base_dir = config["base_dir"]
            @crud_file = config["crud_file"]
            @sheet_name = config["sheet_name"]
            @method_col = config["method_col"]
            @action_col = config["action_col"]
            @table_start_col = config["table_start_col"]
            @sql_logging_enabled = config["sql_logging_enabled"]
            @header_bg_color = config["header_bg_color"]
            @font_name = config["font_name"]

            @last_loaded = File.mtime(@config_file)
          end
        end

        def crud_file_path
          File.join(@base_dir, @crud_file)
        end

        def crud_log_path
          File.join(@base_dir, @crud_log)
        end
      end
    end
  end
end