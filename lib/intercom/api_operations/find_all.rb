require 'intercom/collection_proxy'

module Intercom
  module ApiOperations
    module FindAll
      module ClassMethods
        def find_all(params)
          raise BadRequestError, "#{self}#find takes a hash as its parameter but you supplied #{params.inspect}" unless params.is_a? Hash
          collection_name = Utils.resource_class_to_collection_name(self)
          finder_details = {}
          if params[:id] && !type_switched_finder?(params)
            finder_details[:url] = "/#{collection_name}/#{params[:id]}"
            finder_details[:params] = {}
          else
            finder_details[:url] = "/#{collection_name}"
            finder_details[:params] = params
          end
          CollectionProxy.new(collection_name, finder_details)
        end

        private

        def type_switched_finder?(params)
          params.include?(:type)
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
