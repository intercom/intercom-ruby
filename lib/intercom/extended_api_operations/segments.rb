# frozen_string_literal: true

require 'intercom/client_collection_proxy'
require 'intercom/utils'

module Intercom
  module ExtendedApiOperations
    module Segments
      def by_segment(id)
        collection_name = Utils.resource_class_to_collection_name(collection_class)
        ClientCollectionProxy.new(collection_name, collection_class, details: { url: "/#{collection_name}?segment_id=#{id}" }, client: @client)
      end
    end
  end
end
