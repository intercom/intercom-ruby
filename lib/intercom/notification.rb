require 'intercom/traits/api_resource'

module Intercom
  class Notification
    include Traits::ApiResource

    def model
      data.item
    end

    def model_type
      model.class
    end

    def load
      model.load
    end

  end
end
