require 'intercom/traits/api_resource'

module Intercom
  module ApiOperations
    module Convert
      def convert(contact, user)
        Intercom::User.new.from_response(
          @client.post(
            "/contacts/convert",
            {
              contact: { user_id: contact.user_id },
              user: identity_hash(user)
            }
          )
        )
      end
    end
  end
end
