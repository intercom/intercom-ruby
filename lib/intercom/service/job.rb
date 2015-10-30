require 'intercom/service/base_service'
require 'intercom/api_operations/list'
require 'intercom/api_operations/find_all'
require 'intercom/api_operations/find'
require 'intercom/api_operations/load'
require 'intercom/api_operations/save'
require 'intercom/api_operations/bulk/load_error_feed'

module Intercom
  module Service
    class Job < BaseService
      include ApiOperations::Save
      include ApiOperations::List
      include ApiOperations::FindAll
      include ApiOperations::Find
      include ApiOperations::Load
      include ApiOperations::Bulk::LoadErrorFeed

      def collection_class
        Intercom::Job
      end
    end
  end
end
