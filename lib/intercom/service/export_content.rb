require 'intercom/service/base_service'
require 'intercom/api_operations/find'
require 'intercom/api_operations/list'
require 'intercom/api_operations/save'

module Intercom
  module Service
    class ExportContent < BaseService
      include ApiOperations::Load
      include ApiOperations::List
      include ApiOperations::Find
      include ApiOperations::Save

      def collection_class
        Intercom::ExportContent
      end

      def collection_name
        'export/content/data'
      end

      def cancel(id)
        response = @client.post("/export/cancel/#{id}", {})
        collection_class.new.from_response(response)
      end

    end
  end
end

