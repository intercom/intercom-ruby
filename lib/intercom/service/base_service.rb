module Intercom
  module Service
    class BaseService
      attr_reader :client

      def initialize(client)
        @client = client
      end

      def collection_class
        raise NotImplementedError
      end

      def from_api(api_response)
        object = collection_class.new
        object.from_response(api_response)
        object
      end
    end
  end
end
