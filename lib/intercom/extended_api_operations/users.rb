require 'intercom/client_collection_proxy'
require 'intercom/utils'

module Intercom
  module ExtendedApiOperations
    module Users
      def users(id)
        collection_name = Utils.resource_class_to_collection_name(collection_class)
        finder_details = {}
        finder_details[:url] = "/#{collection_name}/#{id}/users"
        finder_details[:params] = {}
        ClientCollectionProxy.new("users", finder_details: finder_details, client: @client)
      end
    end
  end
end
