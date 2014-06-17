require 'intercom/traits/api_resource'

module Intercom
  module ApiOperations
    module Delete

      def delete
        collection_name = Utils.resource_class_to_collection_name(self.class)
        Intercom.delete("/#{collection_name}/#{id}", {})
        self
      end

    end
  end
end
