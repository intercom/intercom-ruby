require 'intercom/utils'

module Intercom
  module ApiOperations
    module Bulk
      module Submit
        def submit_bulk_job(params)
          raise(ArgumentError, "events do not support bulk delete operations") if collection_class == Intercom::Event && !params.fetch(:delete_items, []).empty?
          data_type = Utils.resource_class_to_singular_name(collection_class)
          collection_name = Utils.resource_class_to_collection_name(collection_class)
          create_items = params.fetch(:create_items, []).map { |item| item_for_api("post", data_type, item) }
          delete_items = params.fetch(:delete_items, []).map { |item| item_for_api("delete", data_type, item) }
          existing_job_id = params.fetch(:job_id, '')

          bulk_request = {
            items: create_items + delete_items
          }
          bulk_request[:job] = { id: existing_job_id } unless existing_job_id.empty?

          response = @client.post("/bulk/#{collection_name}", bulk_request)
          raise Intercom::HttpError.new('Http Error - No response entity returned') unless response
          Intercom::Job.new.from_response(response)
        end

        private

        def item_for_api(method, data_type, item)
          {
            method: method,
            data_type: data_type,
            data: item
          }
        end
      end
    end
  end
end
