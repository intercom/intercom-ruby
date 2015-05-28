require 'intercom/service/base_service'
require 'intercom/api_operations/list'
require 'intercom/api_operations/find_all'
require 'intercom/api_operations/find'
require 'intercom/api_operations/load'
require 'intercom/api_operations/save'

module Intercom
  module Service
    class Note < BaseService
      include ApiOperations::Save
      include ApiOperations::List
      include ApiOperations::FindAll
      include ApiOperations::Find
      include ApiOperations::Load

      def collection_class
        Intercom::Note
      end
    end
  end
end
