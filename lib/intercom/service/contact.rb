require 'intercom/service/base_service'
require 'intercom/api_operations/load'
require 'intercom/api_operations/find'
require 'intercom/api_operations/find_all'
require 'intercom/api_operations/save'
require 'intercom/api_operations/convert'

module Intercom
  module Service
    class Contact < BaseService
      include ApiOperations::Load
      include ApiOperations::Find
      include ApiOperations::FindAll
      include ApiOperations::Save
      include ApiOperations::Convert

      def collection_class
        Intercom::Contact
      end
    end
  end
end
