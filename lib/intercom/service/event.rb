require 'intercom/service/base_service'
require 'intercom/api_operations/save'

module Intercom
  module Service
    class Event < BaseService
      include ApiOperations::Save

      def collection_class
        Intercom::Event
      end
    end
  end
end
