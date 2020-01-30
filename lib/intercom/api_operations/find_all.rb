# frozen_string_literal: true

require 'intercom/client_collection_proxy'
require 'intercom/utils'

module Intercom
  module ApiOperations
    module FindAll
      def find_all(params)
        raise BadRequestError, "#find takes a hash as its parameter but you supplied #{params.inspect}" unless params.is_a? Hash

        finder_details = {}
        if params[:id] && !type_switched_finder?(params)
          finder_details[:url] = "/#{collection_name}/#{params[:id]}"
          finder_details[:params] = {}
        else
          finder_details[:url] = "/#{collection_name}"
          finder_details[:params] = params
        end
        collection_proxy_class.new(collection_name, collection_class, details: finder_details, client: @client)
      end

      private

      def type_switched_finder?(params)
        params.include?(:type)
      end
    end
  end
end
