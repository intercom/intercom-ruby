require 'intercom/search_collection_proxy'
require 'intercom/utils'

module Intercom
  module ApiOperations
    module Search
      def search(params)
        collection_name = Utils.resource_class_to_collection_name(collection_class)
        search_details = {
          url: "/#{collection_name}/search",
          params: params
        }
        SearchCollectionProxy.new(collection_name, search_details: search_details, client: @client)
      end
    end
  end
end
