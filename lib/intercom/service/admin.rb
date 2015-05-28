require 'intercom/service/base_service'
require 'intercom/api_operations/list'

module Intercom
  module Service
    class Admin < BaseService
      include ApiOperations::List

      def collection_class
        Intercom::Admin
      end
    end
  end
end
