require 'logger'
require 'singleton'

module Rails
  module Crud
    class CrudLogger
      include Singleton

      def initialize
        @logger = Logger.new("log/crud.log")
      end

      def self.logger
        instance.logger
      end

      def logger
        @logger
      end
    end
  end
end