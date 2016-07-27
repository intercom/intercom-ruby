require 'intercom/service/base_service'
require 'intercom/api_operations/save'
require 'intercom/api_operations/bulk/submit'

module Intercom
  module Service
    class Event < BaseService
      include ApiOperations::FindAll
      include ApiOperations::Save
      include ApiOperations::Bulk::Submit

      def collection_class
        Intercom::Event
      end
    end
  end
end
