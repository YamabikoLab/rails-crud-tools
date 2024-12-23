require 'rails/railtie'

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