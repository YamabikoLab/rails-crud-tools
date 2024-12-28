module RailsCrud
  module Generators
    class UninstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def remove_javascript
        remove_file 'app/assets/javascripts/rails_crud.js'
      end

      def remove_javascript_include_tag
        gsub_file 'app/views/layouts/application.html.erb', /\n    <%= javascript_include_tag 'rails_crud' %>\n/, ''
      end

      def show_uninstall_message
        puts "Rails CRUD has been successfully uninstalled!"
      end
    end
  end
end