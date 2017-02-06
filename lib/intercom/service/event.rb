require 'intercom/client_collection_proxy'
require 'intercom/service/base_service'
require 'intercom/api_operations/save'
require 'intercom/api_operations/bulk/submit'

module Intercom
  class EventCollectionProxy < ClientCollectionProxy

    def paging_info_present?(response_hash)
      !!(response_hash['pages'])
    end
  end

  module Service
    class Event < BaseService
      include ApiOperations::FindAll
      include ApiOperations::Save
      include ApiOperations::Bulk::Submit

      def collection_class
        Intercom::Event
      end

      def collection_proxy_class
        Intercom::EventCollectionProxy
      end
    end
  end
end
