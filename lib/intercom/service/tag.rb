require 'intercom/service/base_service'
require 'intercom/api_operations/save'
require 'intercom/api_operations/list'
require 'intercom/api_operations/find'
require 'intercom/api_operations/find_all'

module Intercom
  module Service
    class Tag < BaseService
      include ApiOperations::Save
      include ApiOperations::List
      include ApiOperations::Find
      include ApiOperations::FindAll

      def collection_class
        Intercom::Tag
      end

      def tag(params)
        params['tag_or_untag'] = 'tag'
        create(params)
      end

      def untag(params)
        params['tag_or_untag'] = 'untag'
        create(params)
      end
    end
  end
end
