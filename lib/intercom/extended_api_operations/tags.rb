require 'intercom/traits/api_resource'

module Intercom
  module ExtendedApiOperations
    module Tags

      def tags
        collection_name = Utils.resource_class_to_collection_name(self.class)
        self.id ? Intercom::Tag.send("find_all_for_#{collection_name}", :id => id) : []
      end

    end
  end
end
