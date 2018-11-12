require 'intercom/api_operations/list'
require 'intercom/api_operations/find_all'
require 'intercom/api_operations/find'
require 'intercom/api_operations/save'
require 'intercom/api_operations/archive'

module Intercom
  module Service
    class Subscription < BaseService
      include ApiOperations::List
      include ApiOperations::Find
      include ApiOperations::FindAll
      include ApiOperations::Save
      include ApiOperations::Archive

      def collection_class
        Intercom::Subscription
      end
    end
  end
end
