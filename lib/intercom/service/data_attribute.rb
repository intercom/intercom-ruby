require 'intercom/service/base_service'
require 'intercom/api_operations/load'
require 'intercom/api_operations/list'
require 'intercom/api_operations/find_all'
require 'intercom/api_operations/save'

module Intercom
  module Service
    class DataAttribute < BaseService
      include ApiOperations::Load
      include ApiOperations::List
      include ApiOperations::FindAll
      include ApiOperations::Save

      def collection_class
        Intercom::DataAttribute
      end
    end
  end
end
