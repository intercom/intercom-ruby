require 'intercom/service/base_service'
require 'intercom/api_operations/find'
require 'intercom/api_operations/list'
require 'intercom/api_operations/delete'
require 'intercom/api_operations/save'

module Intercom
  module Service
    class Article < BaseService
      include ApiOperations::Find
      include ApiOperations::List
      include ApiOperations::Delete
      include ApiOperations::Save

      def collection_class
        Intercom::Article
      end

      def me
        response = @client.get("/me", {})
        raise Intercom::HttpError.new('Http Error - No response entity returned') unless response
        from_api(response)
      end
    end
  end
end
