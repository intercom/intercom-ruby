require 'intercom/user_resource'

module Intercom

  ##
  # Represents a users interaction with your app (eg page view, or using a particular feature)
  class Impression < UserResource
    ##
    # Records that a user has interacted with your application, including the 'location' within the app they used
    def self.create(params)
      Impression.new(params).save
    end

    def save
      response = Intercom.post("users/impressions", to_hash)
      self.update_from_api_response(response)
    end

    def user_ip=(user_ip)
      @attributes["user_ip"] = user_ip
    end

    def user_ip
      @attributes["user_ip"]
    end

    def location=(location)
      @attributes["location"] = location
    end

    def location
      @attributes["location"]
    end

    def user_agent=(user_agent)
      @attributes["user_agent"] = user_agent
    end

    def user_agent
      @attributes["user_agent"]
    end

    def unread_messages
      @attributes["unread_messages"]
    end
  end
end
