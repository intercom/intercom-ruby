# frozen_string_literal: true

require 'intercom/utils'

module Intercom
  module ApiOperations
    module Find
      def find(params)
        raise BadRequestError, "#{self}#find takes a hash as its parameter but you supplied #{params.inspect}" unless params.is_a? Hash

        if params[:id]
          id = params.delete(:id)
          response = @client.get("/#{collection_name}/#{id}", params)
        else
          response = @client.get("/#{collection_name}", params)
        end
        raise Intercom::HttpError, 'Http Error - No response entity returned' unless response

        from_api(response)
      end
    end
  end
end
