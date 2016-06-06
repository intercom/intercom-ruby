require 'intercom/client_scroll_collection_proxy'

module Intercom
  module ApiOperations
    module Scroll
      def scroll
        collection_name = Utils.resource_class_to_collection_name(collection_class)
        finder_details  = { url: "/#{collection_name}/scroll" }
        ClientScrollCollectionProxy.new(collection_name, finder_details: finder_details,  client: @client)
      end
    end
  end
end
