require 'intercom/traits/api_resource'

module Intercom
  module ApiOperations
    module Convert
      def convert(contact, user = false)
        if contact.class == Intercom::Visitor
          visitor = contact
          req = {
            visitor: { user_id: visitor.user_id },
          }
          if user
            req[:user] = identity_hash(user)
            req[:type] = 'user'
          else
            req[:type] = 'lead'
          end
          Intercom::User.new.from_response(
            @client.post(
              "/visitors/convert", req
            )
          )
        else
          Intercom::User.new.from_response(
            @client.post(
              "/contacts/convert", {
                contact: { user_id: contact.user_id },
                user: identity_hash(user)
              }
            )
          )
        end
      end
    end
  end
end
