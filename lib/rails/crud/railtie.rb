require 'rails/railtie'
require_relative 'crud_operations_logger'

module Rails
  module Crud
    class Railtie < ::Rails::Railtie
      initializer 'rails-crud.add_after_action' do
        ActiveSupport.on_load(:action_controller) do
          include Rails::Crud::OperationsLogger
        end
      end
    end
  end
end