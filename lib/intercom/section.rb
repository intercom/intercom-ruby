require 'intercom/api_operations/list'
require 'intercom/api_operations/find'
require 'intercom/api_operations/save'
require 'intercom/api_operations/delete'

module Intercom
  module Service
    class Section < BaseService
      include ApiOperations::List
      include ApiOperations::Find
      include ApiOperations::Save
      include ApiOperations::Delete

      def collection_class
        Intercom::Section
      end

      def collection_name
        'help_center/sections'
      end
    end
  end
end
