require 'intercom/api_operations/list'
require 'intercom/api_operations/find_all'
require 'intercom/api_operations/find'

module Intercom
  module Service
    class SubscriptionType < BaseService
      include ApiOperations::List
      include ApiOperations::Find
      include ApiOperations::FindAll
      include ApiOperations::Delete

      def collection_class
        Intercom::SubscriptionType
      end
    end
  end
end
