require 'intercom/service/base_service'
require 'intercom/api_operations/load'
require 'intercom/api_operations/list'
require 'intercom/api_operations/find'
require 'intercom/api_operations/find_all'
require 'intercom/api_operations/save'
require 'intercom/api_operations/convert'
require 'intercom/api_operations/archive'

module Intercom
  module Service
    class Visitor < BaseService
      include ApiOperations::Load
      include ApiOperations::List
      include ApiOperations::Find
      include ApiOperations::FindAll
      include ApiOperations::Save
      include ApiOperations::Convert
      include ApiOperations::Archive

      def collection_class
        Intercom::Visitor
      end
    end
  end
end
