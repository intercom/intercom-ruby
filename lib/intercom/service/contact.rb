require 'intercom/service/base_service'
require 'intercom/api_operations/load'
require 'intercom/api_operations/list'
require 'intercom/api_operations/find'
require 'intercom/api_operations/save'
require 'intercom/api_operations/delete'
require 'intercom/api_operations/search'

module Intercom
  module Service
    class Contact < BaseService
      include ApiOperations::Load
      include ApiOperations::List
      include ApiOperations::Find
      include ApiOperations::Save
      include ApiOperations::Delete
      include ApiOperations::Search

      def collection_class
        Intercom::Contact
      end

      def collection_proxy_class
        Intercom::BaseCollectionProxy
      end

      def merge(lead, user)
        raise_invalid_merge_error unless lead.role == 'lead' && user.role == 'user'

        response = @client.post('/contacts/merge', from: lead.id, into: user.id)
        raise Intercom::HttpError, 'Http Error - No response entity returned' unless response

        user.from_response(response)
      end

      def archive(contact)
        @client.post("/#{collection_name}/#{contact.id}/archive", {})
        contact
      end

      def unarchive(contact)
        @client.post("/#{collection_name}/#{contact.id}/unarchive", {})
        contact
      end

      private def raise_invalid_merge_error
        raise Intercom::InvalidMergeError, 'Merging can only be performed on a lead into a user'
      end
    end
  end
end
