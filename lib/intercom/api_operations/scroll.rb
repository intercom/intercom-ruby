# frozen_string_literal: true

require 'intercom/scroll_collection_proxy'
require 'intercom/utils'

module Intercom
  module ApiOperations
    module Scroll
      def scroll
        finder_details = {}
        finder_details[:url] = "/#{collection_name}"
        ScrollCollectionProxy.new(collection_name, collection_class, details: finder_details, client: @client)
      end
    end
  end
end
