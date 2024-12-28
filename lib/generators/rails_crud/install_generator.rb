module RailsCrudCrud
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def copy_javascript
        copy_file 'rails_crud.js', 'app/assets/javascripts/rails_crud.js'
      end

      def add_javascript_include_tag
        inject_into_file 'app/views/layouts/application.html.erb', before: '</head>' do
          "\n    <%= javascript_include_tag 'rails_crud' %>\n"
        end
      end

      def add_javascript_require
        append_to_file 'app/assets/javascripts/application.js' do
          "\n//= require rails_crud\n"
        end
      end

      def show_install_message
        puts "Rails CRUD has been successfully installed!"
      end

      # メソッドの呼び出し順序を定義
      def install
        copy_javascript
        add_javascript_include_tag
        add_javascript_require
        show_install_message
      end
    end
  end
end