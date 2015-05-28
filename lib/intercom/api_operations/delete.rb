require 'intercom/traits/api_resource'

module Intercom
  module ApiOperations
    module Delete
      def delete(object)
        collection_name = Utils.resource_class_to_collection_name(collection_class)
        @client.delete("/#{collection_name}/#{object.id}", {})
        object
      end
    end
  end
end
