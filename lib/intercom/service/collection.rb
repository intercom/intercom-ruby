require 'intercom/service/base_service'
require 'intercom/api_operations/list'
require 'intercom/api_operations/find'
require 'intercom/api_operations/delete'
require 'intercom/api_operations/save'

module Intercom
  module Service
    class Collection < BaseService
      include ApiOperations::List
      include ApiOperations::Find
      include ApiOperations::Delete
      include ApiOperations::Save

      def collection_class
        Intercom::Collection
      end

      def collection_name
        "help_center/collections"
      end
    end
  end
end
