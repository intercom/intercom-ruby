require 'intercom/service/base_service'
require 'intercom/api_operations/search'

module Intercom
  module Service
    class Customer < BaseService
      include ApiOperations::Search

      def collection_class
        Intercom::Customer
      end
    end
  end
end
