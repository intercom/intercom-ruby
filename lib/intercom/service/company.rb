require 'intercom/service/base_service'
require 'intercom/api_operations/list'
require 'intercom/api_operations/scroll'
require 'intercom/api_operations/find'
require 'intercom/api_operations/find_all'
require 'intercom/api_operations/save'
require 'intercom/api_operations/load'
require 'intercom/extended_api_operations/users'
require 'intercom/extended_api_operations/tags'
require 'intercom/extended_api_operations/segments'

module Intercom
  module Service
    class Company < BaseService
      include ApiOperations::Find
      include ApiOperations::FindAll
      include ApiOperations::Load
      include ApiOperations::List
      include ApiOperations::Scroll
      include ApiOperations::Save
      include ExtendedApiOperations::Tags
      include ExtendedApiOperations::Segments

      def collection_class
        Intercom::Company
      end

      def users_by_intercom_company_id(id)
        get_users(url: "/companies/#{id}/users")
      end

      def users_by_company_id(id)
        get_users(url: "/companies", params: { company_id: id, type: "user" })
      end

      private def get_users(url:, params: {})
        ClientCollectionProxy.new("users", finder_details: { url: url, params: params }, client: @client)
      end
    end
  end
end
