require 'intercom/service/base_service'
require 'intercom/api_operations/list'

module Intercom
  module Service
    class Tour < BaseService
      include ApiOperations::List

      def collection_class
        Intercom::Tour
      end
    end
  end
end
