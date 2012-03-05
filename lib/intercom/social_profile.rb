require 'intercom/user_resource'

module Intercom
  ##
  # object representing a social profile for the User (see )http://docs.intercom.io/#SocialProfiles)
  class SocialProfile < UserResource
    def for_wire #:nodoc:
      @attributes
    end

    def type
      @attributes["type"]
    end

    def type=(type)
      @attributes["type"]=type
    end

    def id
      @attributes["id"]
    end

    def id=(id)
      @attributes["id"]=id
    end

    def url
      @attributes["url"]
    end

    def url=(url)
      @attributes["url"]=url
    end

    def username
      @attributes["username"]
    end

    def username=(username)
      @attributes["username"]=username
    end
  end
end
