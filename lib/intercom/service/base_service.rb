# frozen_string_literal: true

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

      def collection_name
        @collection_name ||= Utils.resource_class_to_collection_name(collection_class)
      end

      def from_api(api_response)
        object = collection_class.new
        object.client = @client
        object.from_response(api_response)
        object
      end
    end
  end
end
