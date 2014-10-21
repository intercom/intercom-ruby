module Intercom
  module ApiOperations
    module Find
      module ClassMethods
        def find(params)
          raise BadRequestError, "#{self}#find takes a hash as its parameter but you supplied #{params.inspect}" unless params.is_a? Hash
          collection_name = Utils.resource_class_to_collection_name(self)
          if params[:id]
            response = Intercom.get("/#{collection_name}/#{params[:id]}", {})
          else
            response = Intercom.get("/#{collection_name}", params)
          end
          raise Intercom::HttpError.new('Http Error - No response entity returned') unless response
          from_api(response)
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
