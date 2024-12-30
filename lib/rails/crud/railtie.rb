# lib/rails/crud/railtie.rb
require 'rails/railtie'
require_relative 'crud_operations_logger'

module Rails
  module Crud
    class Railtie < ::Rails::Railtie
      initializer 'rails-crud.add_after_action' do
        ActiveSupport.on_load(:action_controller) do
          logger = Rails::Crud::OperationsLogger.new

          # 全てのコントローラにafter_actionフィルタを追加
          ActionController::Base.class_eval do
            around_action do |controller, action|
              logger.log_crud_operations { action.call }
            end
          end

          # APIモードの場合はActionController::APIにも追加
          ActionController::API.class_eval do
            around_action do |controller, action|
              logger.log_crud_operations { action.call }
            end
          end
        end

        # ActiveJobにもフィルタを追加
        ActiveSupport.on_load(:active_job) do
          # 全てのジョブにaround_performフィルタを追加
          ActiveJob::Base.class_eval do
            around_perform do |job, block|
              logger.log_crud_operations_for_job { block.call }
            end
          end
        end
      end
    end
  end
end