require 'intercom/service/base_service'
require 'intercom/api_operations/list'
require 'intercom/api_operations/find'

module Intercom
  module Service
    class Team < BaseService
      include ApiOperations::List
      include ApiOperations::Find

      def collection_class
        Intercom::Team
      end

    end
  end
end