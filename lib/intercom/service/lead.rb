# frozen_string_literal: true

require 'intercom/service/base_service'
require 'intercom/api_operations/load'
require 'intercom/api_operations/list'
require 'intercom/api_operations/find'
require 'intercom/api_operations/find_all'
require 'intercom/api_operations/save'
require 'intercom/api_operations/scroll'
require 'intercom/api_operations/convert'
require 'intercom/api_operations/archive'
require 'intercom/api_operations/request_hard_delete'
require 'intercom/deprecated_leads_collection_proxy'

module Intercom
  module Service
    class Lead < BaseService
      include ApiOperations::Load
      include ApiOperations::List
      include ApiOperations::Find
      include ApiOperations::FindAll
      include ApiOperations::Save
      include ApiOperations::Scroll
      include ApiOperations::Convert
      include ApiOperations::Archive
      include ApiOperations::RequestHardDelete

      def collection_proxy_class
        Intercom::DeprecatedLeadsCollectionProxy
      end

      def collection_class
        Intercom::Lead
      end

      def collection_name
        'contacts'
      end
    end
  end
end
