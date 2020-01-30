require 'intercom/service/base_service'
require 'intercom/api_operations/find'

module Intercom
  module Service
    class Note < BaseService
      include ApiOperations::Find

      def collection_class
        Intercom::Note
      end

      def collection_proxy_class
        Intercom::BaseCollectionProxy
      end
    end
  end
end
