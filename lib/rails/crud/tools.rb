require_relative "tools/crud_notifications"
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