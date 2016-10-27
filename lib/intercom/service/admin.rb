require 'intercom/service/base_service'
require 'intercom/api_operations/list'
require 'intercom/api_operations/find'

module Intercom
  module Service
    class Admin < BaseService
      include ApiOperations::List
      include ApiOperations::Find

      def collection_class
        Intercom::Admin
      end

      def me
        response = @client.get("/me", {})
        raise Intercom::HttpError.new('Http Error - No response entity returned') unless response
        from_api(response)
      end
    end
  end
end
