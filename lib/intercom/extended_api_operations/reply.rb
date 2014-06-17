require 'intercom/traits/api_resource'

module Intercom
  module ExtendedApiOperations
    module Reply

      def reply(reply_data)
        collection_name = Utils.resource_class_to_collection_name(self.class)
        # TODO: For server, we should not need to merge in :conversation_id here (already in the URL)
        response = Intercom.post("/#{collection_name}/#{id}/reply", reply_data.merge(:conversation_id => id))
        from_response(response)
      end

    end
  end
end
