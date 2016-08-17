require 'intercom/service/base_service'
require 'intercom/api_operations/load'
require 'intercom/api_operations/list'
require 'intercom/api_operations/scroll'
require 'intercom/api_operations/find'
require 'intercom/api_operations/find_all'
require 'intercom/api_operations/save'
require 'intercom/api_operations/delete'
require 'intercom/api_operations/bulk/submit'
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
      include ApiOperations::Delete
      include ApiOperations::Bulk::Submit
      include ExtendedApiOperations::Tags
      include ExtendedApiOperations::Segments

      def collection_class
        Intercom::User
      end
    end
  end
end
