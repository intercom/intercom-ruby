# frozen_string_literal: true

require 'intercom/utils'

module Intercom
  module ApiOperations
    module Load
      def load(object)
        if object.id
          response = @client.get("/#{collection_name}/#{object.id}", {})
        else
          raise "Cannot load #{collection_class} as it does not have a valid id."
        end
        raise Intercom::HttpError, 'Http Error - No response entity returned' unless response

        object.from_response(response)
      end
    end
  end
end
