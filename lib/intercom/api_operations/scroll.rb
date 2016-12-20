require 'intercom/scroll_collection_proxy'
require 'intercom/utils'

module Intercom
  module ApiOperations
    module Scroll

      def scroll()
        collection_name = Utils.resource_class_to_collection_name(collection_class)
        finder_details = {}
        finder_details[:url] = "/#{collection_name}"
        ScrollCollectionProxy.new(collection_name, finder_details: finder_details,  client: @client)
      end

    end
  end
end
