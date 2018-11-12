require 'intercom/service/base_service'
require 'intercom/api_operations/load'
require 'intercom/api_operations/list'
require 'intercom/api_operations/scroll'
require 'intercom/api_operations/find'
require 'intercom/api_operations/find_all'
require 'intercom/api_operations/save'
require 'intercom/api_operations/archive'
require 'intercom/api_operations/bulk/submit'
require 'intercom/api_operations/request_hard_delete'
require 'intercom/extended_api_operations/tags'
require 'intercom/extended_api_operations/segments'

module Intercom
  module Service
    class User < BaseService
      include ApiOperations::Load
      include ApiOperations::List
      include ApiOperations::Scroll
      include ApiOperations::Find
      include ApiOperations::FindAll
      include ApiOperations::Save
      include ApiOperations::Archive
      include ApiOperations::RequestHardDelete
      include ApiOperations::Bulk::Submit
      include ExtendedApiOperations::Tags
      include ExtendedApiOperations::Segments

      def collection_class
        Intercom::User
      end
    end
  end
end
