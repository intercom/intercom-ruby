require 'intercom/service/base_service'
require 'intercom/api_operations/save'
require 'intercom/api_operations/list'
require 'intercom/api_operations/find_all'
require 'intercom/api_operations/find'

module Intercom
  module Service
    class Tag < BaseService
      include ApiOperations::Save
      include ApiOperations::List
      include ApiOperations::FindAll
      include ApiOperations::Delete
      include ApiOperations::Find

      def collection_class
        Intercom::Tag
      end

      def collection_proxy_class
        Intercom::BaseCollectionProxy
      end

      def tag(params)
        params['tag_or_untag'] = 'tag'
        create(params)
      end

      def untag(params)
        params['tag_or_untag'] = 'untag'
        params[:companies].each do |company|
          company[:untag] = true
        end
        create(params)
      end
    end
  end
end
