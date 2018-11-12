require 'intercom/service/base_service'
require 'intercom/api_operations/load'
require 'intercom/api_operations/list'
require 'intercom/api_operations/find'
require 'intercom/api_operations/find_all'
require 'intercom/api_operations/save'
require 'intercom/api_operations/scroll'
require 'intercom/api_operations/convert'
require 'intercom/api_operations/archive'
require 'intercom/api_operations/request_hard_delete'

module Intercom
  module Service
    class Contact < BaseService
      include ApiOperations::Load
      include ApiOperations::List
      include ApiOperations::Find
      include ApiOperations::FindAll
      include ApiOperations::Save
      include ApiOperations::Scroll
      include ApiOperations::Convert
      include ApiOperations::Delete

      def collection_class
        Intercom::Contact
      end
    end
  end
end
