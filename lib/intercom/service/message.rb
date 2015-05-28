require 'intercom/service/base_service'
require 'intercom/api_operations/save'

module Intercom
  module Service
    class Message < BaseService
      include ApiOperations::Save

      def collection_class
        Intercom::Message
      end
    end
  end
end
