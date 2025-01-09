# frozen_string_literal: true

require "logger"
require "singleton"

module Rails
  module Crud
    module Tools
      # The CrudLogger class is responsible for logging CRUD operations to a file.
      # It uses the Singleton pattern to ensure only one instance of the logger exists.
      class CrudLogger
        include Singleton

        attr_reader :logger

        def initialize
          @logger = Logger.new("log/crud.log")
        end

        def self.logger
          instance.logger
        end
      end
    end
  end
end
