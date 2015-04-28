require 'intercom/traits/api_resource'

module Intercom
  module ApiOperations
    module Convert
      def convert(user)
        from_response(
          Intercom.post(
            "/contacts/convert",
            {
              contact: { user_id: user_id },
              user: user.identity_hash
            }
          )
        )
      end
    end
  end
end
