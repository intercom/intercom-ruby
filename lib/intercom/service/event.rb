require 'intercom/service/base_service'
require 'intercom/api_operations/save'
require 'intercom/api_operations/bulk/submit'
require 'intercom/api_operations/find'

module Intercom
  module Service
    class Event < BaseService
      include ApiOperations::Save
      include ApiOperations::Find
      include ApiOperations::Bulk::Submit

      def collection_class
        Intercom::Event
      end
    end
  end
end
