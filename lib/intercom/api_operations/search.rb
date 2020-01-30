# frozen_string_literal: true

require 'intercom/search_collection_proxy'
require 'intercom/utils'

module Intercom
  module ApiOperations
    module Search
      def search(params)
        search_details = {
          url: "/#{collection_name}/search",
          params: params
        }
        SearchCollectionProxy.new(collection_name, collection_class, details: search_details, client: @client)
      end
    end
  end
end
