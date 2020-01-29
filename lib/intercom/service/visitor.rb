require 'intercom/service/base_service'
require 'intercom/api_operations/load'
require 'intercom/api_operations/find'
require 'intercom/api_operations/save'
require 'intercom/api_operations/delete'

module Intercom
  module Service
    class Visitor < BaseService
      include ApiOperations::Load
      include ApiOperations::Find
      include ApiOperations::Save
      include ApiOperations::Delete

      def collection_class
        Intercom::Visitor
      end

      def convert(visitor, contact = false)
        req = { visitor: { user_id: visitor.user_id } }
        if contact
          req[:user] = identity_hash(contact)
          req[:type] = 'user'
        else
          req[:type] = 'lead'
        end
        Intercom::Contact.new.from_response(
          @client.post(
            "/visitors/convert", req
          )
        )
      end
    end
  end
end
