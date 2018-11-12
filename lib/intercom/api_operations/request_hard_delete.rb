require 'intercom/utils'

module Intercom
  module ApiOperations
    module RequestHardDelete
      def request_hard_delete(object)
        @client.post("/user_delete_requests", {intercom_user_id: object.id})
        object
      end
    end
  end
end
