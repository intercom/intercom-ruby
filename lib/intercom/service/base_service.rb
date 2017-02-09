require 'intercom/client_collection_proxy'

module Intercom
  module Service
    class BaseService
      attr_reader :client

      def initialize(client)
        @client = client
      end

      def collection_class
        raise NotImplementedError
      end

      def collection_proxy_class
        Intercom::ClientCollectionProxy
      end

      def from_api(api_response)
        object = collection_class.new
        object.from_response(api_response)
        object
      end
    end
  end
end
