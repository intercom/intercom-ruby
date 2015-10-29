module Intercom
  module ApiOperations
    module Bulk
      module LoadErrorFeed
        def errors(params)
          response = @client.get("/jobs/#{params.fetch(:id)}/error", {})
          raise Intercom::HttpError.new('Http Error - No response entity returned') unless response
          from_api(response)
        end
      end
    end
  end
end
