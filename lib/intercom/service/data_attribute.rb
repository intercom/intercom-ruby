require 'intercom/service/base_service'
require 'intercom/extended_api_operations/data_attributes'

module Intercom
  module Service
    class DataAttribute < BaseService
      include ExtendedApiOperations::DataAttributes

      def collection_class
        Intercom::DataAttribute
      end
    end
  end
end
