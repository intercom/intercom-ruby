require 'intercom/service/base_service'
require 'intercom/api_operations/save'

module Intercom
  module Service
    class PhoneCallRedirect < BaseService
      include ApiOperations::Save

      def collection_class
        Intercom::PhoneCallRedirect
      end

    end
  end
end
