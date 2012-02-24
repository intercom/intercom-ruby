require 'intercom/intercom_object'
require 'intercom/shallow_hash'
require 'intercom/social_profile'

module Intercom
  ##
  # Represents a user of your application on Intercom.
  class User < IntercomObject
    standard_attributes :email, :user_id, :name, :session_count

    ##
    # Fetches an Intercom::User from our API.
    #
    # Calls GET https://api.intercom.io/api/v1/users
    #
    # returns Intercom::User object representing the state on our servers.
    #
    def self.find(params)
      allows_parameters(params, [])
      response = Intercom.get("users", params)
      User.new(response)
    end

    ##
    # Creates (or updates when a user already exists for that email/user_id) a user record on your application.
    #
    # Calls POST https://api.intercom.io/api/v1/users
    #
    # returns Intercom::User object representing the state on our servers.
    #
    # This operation is idempotent.
    def self.create(params)
      allows_parameters(params, %W(name custom_data created_at))
      User.new(params).save
    end

    ##
    # instance method alternative to #create
    def save
      response = Intercom.post("users", to_hash)
      self.attributes=(response)
      self
    end

    ##
    # Get last time this User interacted with your application
    def last_impression_at
      time_at("last_impression_at")
    end

    ##
    # Get Time at which this User started using your application.
    def created_at
      time_at("created_at")
    end

    ##
    # Get Time at which this User started using your application.
    def created_at=(time)
      set_time_at("created_at", time)
    end

    ##
    # Get array of Intercom::SocialProfile objects attached to this Intercom::User
    #
    # See http://docs.intercom.io/#SocialProfiles for more information
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
    def location_data
      @location_data ||= {}.freeze
    end

    ##
    # Get hash of custom attributes stored for this Intercom::User
    #
    # See http://docs.intercom.io/#CustomData for more information
    def custom_data
      @attributes["custom_data"] ||= ShallowHash.new
    end

    private
    def social_profiles=(social_profiles)
      @social_profiles = social_profiles.map { |account| SocialProfile.new(account) }.freeze
    end

    def location_data=(hash)
      @location_data = hash.freeze
    end
  end
end
