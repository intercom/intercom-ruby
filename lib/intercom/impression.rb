require 'intercom/intercom_object'

module Intercom

  ##
  # Represents a users interaction with your app (eg page view, or using a particular feature)
  class Impression < IntercomObject
    ##
    # Records that a user has interacted with your application, including the 'location' within the app they used
    def self.create(params)
      requires_parameters(params, "location") # maybe it's optional
      Impression.new(Intercom.post("impressions", params))
    end
  end
end
