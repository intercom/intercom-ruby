require 'intercom/service/base_service'
require 'intercom/api_operations/find'

module Intercom
  module Service
    class Counts < BaseService
      include ApiOperations::Find

      def collection_class
        Intercom::Count
      end

      def for_app
        find({})
      end

      def for_type(type:, count: nil)
        params = {type: type}
        params[:count] = count if count
        find(params)
      end
    end
  end
end
