# frozen_string_literal: true

require "yaml"
require "singleton"

module Rails
  module Crud
    module Tools
      # The CrudConfig class is a singleton class responsible for loading and managing configuration settings from a YAML file (.crudconfig.yml).
      # It ensures that the configuration is reloaded if the file is updated.
      class CrudConfig
        include Singleton

        CONFIG_PATH = File.expand_path(".crudconfig.yml", Dir.pwd)

        def initialize
          @last_loaded_time = Time.at(0)
        end

        def self.config_path
          CONFIG_PATH
        end

        def config
          load_config if @config.nil? || config_file_updated?
          @config
        end

        def load_config
          @config = deep_convert_to_struct(YAML.load_file(CONFIG_PATH))
          @last_loaded_time = File.mtime(CONFIG_PATH)
        rescue Errno::ENOENT
          raise "Configuration file not found: #{CONFIG_PATH}"
        rescue Psych::SyntaxError => e
          raise "YAML syntax error occurred while parsing #{CONFIG_PATH}: #{e.message}"
        end

        private

        def config_file_updated?
          File.mtime(CONFIG_PATH) > @last_loaded_time
        end

        # Recursively convert hash to Struct and add crud_file_path method
        def deep_convert_to_struct(hash)
          struct_class = Struct.new(*hash.keys.map(&:to_sym)) do
            def crud_file_path
              File.join(base_dir, crud_file.file_name)
            end
          end
          struct_class.new(*hash.values.map { |value| value.is_a?(Hash) ? deep_convert_to_struct(value) : value })
        end
      end
    end
  end
end
