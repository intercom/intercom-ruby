require 'intercom/client_collection_proxy'
require 'intercom/utils'

module Intercom
  module ExtendedApiOperations
    module DataAttributes
      def customer
        list_data_attributes("customer")
      end

      def company
        list_data_attributes("company")
      end

      private

      def list_data_attributes(model)
        collection_name = "data_attributes"
        ClientCollectionProxy.new(collection_name, finder_details: {url: "/#{collection_name}/#{model}"}, client: @client)
      end
    end
  end
end
