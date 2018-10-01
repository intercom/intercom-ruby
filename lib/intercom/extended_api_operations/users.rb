require 'intercom/client_collection_proxy'
require 'intercom/utils'

module Intercom
  module ExtendedApiOperations
    module Users
      def users(params)
        raise BadRequestError, "#{self}#users takes a hash as its parameter but you supplied #{params.inspect}" unless params.is_a? Hash
        collection_name = Utils.resource_class_to_collection_name(collection_class)
        finder_details = {}
        if params[:id]
          finder_details[:url] = "/#{collection_name}/#{params[:id]}/users"
          finder_details[:params] = {}
        elsif params[:company_id]
          finder_details[:url] = "/#{collection_name}"
          finder_details[:params] = {company_id: params[:company_id], type: "user"}
        else raise BadRequestError, "must submit a hash with either id or company_id"
        end
        ClientCollectionProxy.new("users", finder_details: finder_details, client: @client)
      end
    end
  end
end
