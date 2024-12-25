require 'rails/railtie'
require_relative 'crud_operations_logger'

module Rails
  module Crud
    class Railtie < ::Rails::Railtie
      initializer 'rails-crud.add_after_action' do
        ActiveSupport.on_load(:action_controller) do
          include Rails::Crud::OperationsLogger

          # 全てのコントローラにafter_actionフィルタを追加
          ActionController::Base.class_eval do
            around_action :log_crud_operations
          end

          # APIモードの場合はActionController::APIにも追加
          ActionController::API.class_eval do
            around_action :log_crud_operations
          end
        end
      end
    end
  end
end