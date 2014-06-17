require 'intercom/traits/api_resource'

module Intercom
  module ExtendedApiOperations
    module Users

      def users
        collection_name = Utils.resource_class_to_collection_name(self.class)
        finder_details = {}
        finder_details[:url] = "/#{collection_name}/#{id}/users"
        finder_details[:params] = {}
        CollectionProxy.new("users", finder_details)
      end

    end
  end
end
