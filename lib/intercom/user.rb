require 'intercom/user_resource'
require 'intercom/user_custom_data'
require 'intercom/social_profile'

module Intercom
  ##
  # Represents a user of your application on Intercom.
  class User < UserResource
    ##
    # Fetches an Intercom::User from our API.
    #
    # Calls GET https://api.intercom.io/v1/users
    #
    # returns Intercom::User object representing the state on our servers.
    #
    # @return [User]
    def self.find(params)
      response = Intercom.get("users", params)
      User.from_api(response)
    end

    ##
    # Creates (or updates when a user already exists for that email/user_id) a user record on your application.
    #
    # Calls POST https://api.intercom.io/v1/users
    #
    # returns Intercom::User object representing the state on our servers.
    #
    # This operation is idempotent.
    # @return [User]
    def self.create(params)
      User.new(params).save
    end

    # instance method alternative to #create
    # @return [User]
    def save
      response = Intercom.post("users", to_hash)
      self.update_from_api_response(response)
    end

    # @return {User}
    def name
      @attributes["name"]
    end

    def name=(name)
      @attributes["name"]=name
    end

    # @return [String]
    def last_seen_ip
      @attributes["last_seen_ip"]
    end

    def last_seen_ip=(last_seen_ip)
      @attributes["last_seen_ip"]=last_seen_ip
    end

    # @return [String]
    def last_seen_user_agent
      @attributes["last_seen_user_agent"]
    end

    def last_seen_user_agent=(last_seen_user_agent)
      @attributes["last_seen_user_agent"]=last_seen_user_agent
    end

    # @return [Integer]
    def relationship_score
      @attributes["relationship_score"]
    end

    # @return [Integer]
    def session_count
      @attributes["session_count"]
    end

    ##
    # Get last time this User interacted with your application
    # @return [Time]
    def last_impression_at
      time_at("last_impression_at")
    end

    ##
    # Get Time at which this User started using your application.
    # @return [Time]
    def created_at
      time_at("created_at")
    end

    ##
    # Set Time at which this User started using your application.
    def created_at=(time)
      set_time_at("created_at", time)
    end

    ##
    # Get array of Intercom::SocialProfile objects attached to this Intercom::User
    #
    # See http://docs.intercom.io/#SocialProfiles for more information
    # @return [Array<SocialProfile>]
    def social_profiles
      @social_profiles ||= [].freeze
    end

    ##
    # Get hash of location attributes associated with this Intercom::User
    #
    # Possible entries: city_name, continent_code, country_code, country_name, latitude, longitude, postal_code, region_name, timezone
    #
    # e.g.
    #
    #    {"city_name"=>"Santiago", "continent_code"=>"SA", "country_code"=>"CHL", "country_name"=>"Chile",
    #     "latitude"=>-33.44999999999999, "longitude"=>-70.6667, "postal_code"=>"", "region_name"=>"12",
    #     "timezone"=>"Chile/Continental"}
    # @return [Hash]
    def location_data
      @location_data ||= {}.freeze
    end

    # Custom attributes stored for this Intercom::User
    #
    # See http://docs.intercom.io/#CustomData for more information
    #
    # Example: Reading custom_data value for an existing user
    #  user = Intercom::User.find(:email => "someone@example.com")
    #  puts user.custom_data[:plan]
    #
    # Example: Setting some custom data for an existing user
    #  user = Intercom::User.find(:email => "someone@example.com")
    #  user.custom_data[:plan] = "pro"
    #  user.save
    #
    # @return [UserCustomData]
    def custom_data
      @attributes["custom_data"] ||= UserCustomData.new
    end

    # Set a {Hash} of custom data attributes to save/update on this user
    #
    # @param [Hash] custom_data
    # @return [UserCustomData]
    def custom_data=(custom_data)
      @attributes["custom_data"] = UserCustomData.new(custom_data)
    end

    protected
    def social_profiles=(social_profiles) #:nodoc:
      @social_profiles = social_profiles.map { |account| SocialProfile.new(account) }.freeze
    end

    def location_data=(hash) #:nodoc:
      @location_data = hash.freeze
    end
  end
end
