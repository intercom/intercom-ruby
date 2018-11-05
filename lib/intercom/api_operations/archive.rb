require 'intercom/utils'

module Intercom
  module ApiOperations
    module Archive
      def archive(object)
        collection_name = Utils.resource_class_to_collection_name(collection_class)
        @client.delete("/#{collection_name}/#{object.id}", {})
        object
      end

      alias_method 'delete', 'archive'
    end
  end
end
