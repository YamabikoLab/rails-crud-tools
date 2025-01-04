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
    module Tools
      def self.setup()
        return unless File.exist?(".crudconfig")

        CrudData.instance.load_crud_data
        setup_notifications
      end

      setup
    end
  end
end