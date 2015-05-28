module Intercom
  module ApiOperations
    module Find
      def find(params)
        raise BadRequestError, "#{self}#find takes a hash as its parameter but you supplied #{params.inspect}" unless params.is_a? Hash
        collection_name = Utils.resource_class_to_collection_name(collection_class)
        if params[:id]
          response = @client.get("/#{collection_name}/#{params[:id]}", {})
        else
          response = @client.get("/#{collection_name}", params)
        end
        raise Intercom::HttpError.new('Http Error - No response entity returned') unless response
        from_api(response)
      end
    end
  end
end
