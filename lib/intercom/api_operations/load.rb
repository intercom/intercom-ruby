module Intercom
  module ApiOperations
    module Load
      def load
        collection_name = Utils.resource_class_to_collection_name(self.class)
        if id
          response = Intercom.get("/#{collection_name}/#{id}", {})
        else
          raise "Cannot load #{self.class} as it does not have a valid id."
        end
        raise Intercom::HttpError.new('Http Error - No response returned') unless response
        from_response(response)
      end
    end
  end
end
