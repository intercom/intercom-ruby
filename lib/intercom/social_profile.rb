require 'intercom/user_resource'

module Intercom
  # object representing a social profile for the User (see )http://docs.intercom.io/#SocialProfiles).
  # Read only part of the {User} object
  class SocialProfile
    # @return  [String] type e.g. twitter, facebook etc.
    attr_reader :type
    # @return  [String] id
    attr_reader :id
    # @return  [String] url
    attr_reader :url
    # @return [String] username
    attr_reader :username

    # @private
    def initialize(params)
      @type = params["type"]
      @id = params["id"]
      @url = params["url"]
      @username = params["username"]
    end
  end
end
