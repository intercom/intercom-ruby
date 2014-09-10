require 'intercom/traits/api_resource'

module Intercom
  module Webhook
    class Payload
      include Traits::ApiResource

      # This method could be renamed, e.g. response_object or model
      def to_model
        data.item
      end

      def model_type
        to_model.class
      end

      def load
        to_model.load
      end
    end
  end
end
