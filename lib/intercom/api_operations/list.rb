# frozen_string_literal: true

require 'intercom/client_collection_proxy'
require 'intercom/base_collection_proxy'
require 'intercom/utils'

module Intercom
  module ApiOperations
    module List
      def all
        collection_proxy_class.new(collection_name, collection_class, client: @client)
      end
    end
  end
end
