require 'rails/railtie'
require_relative 'crud_operations_logger'

module Rails
  module Crud
    module Tools
      class Railtie < ::Rails::Railtie
        initializer 'rails-crud.add_after_action' do
          ActiveSupport.on_load(:action_controller) do
            include Rails::Crud::Tools::OperationsLogger

            # 全てのコントローラにafter_actionフィルタを追加
            ActionController::Base.class_eval do
              around_action :log_crud_operations
            end

            # APIモードの場合はActionController::APIにも追加
            ActionController::API.class_eval do
              around_action :log_crud_operations
            end
          end

          # ActiveJobにもフィルタを追加
          ActiveSupport.on_load(:active_job) do
            include Rails::Crud::Tools::OperationsLogger

            # 全てのジョブにaround_performフィルタを追加
            ActiveJob::Base.class_eval do
              around_perform :log_crud_operations_for_job
            end
          end
        end
      end
    end
  end
end