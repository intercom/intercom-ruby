require 'intercom/traits/api_resource'

module Intercom
  module ExtendedApiOperations
    module BulkCreate
      MAX_BATCH_SIZE = 50

      def bulk_create(resources)
        unless resources.is_a? Array
          raise ArgumentError, '.bulk_create requires Array parameter'
        end

        collection_name = Utils.resource_class_to_collection_name(collection_class)
        all_instances_params = resources.map do |resource|
          collection_class.new(resource).to_submittable_hash
        end

        all_instances_params.each_slice(MAX_BATCH_SIZE) do |instances_params|
          @client.post("/#{collection_name}/bulk", { collection_name => instances_params })
        end
      end
    end
  end
end
