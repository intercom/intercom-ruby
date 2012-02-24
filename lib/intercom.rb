require "intercom/version"
require "rest_client"
require 'json'

##
# Intercom is a customer relationship management and messaging tool for web app owners
#
# This library provides ruby bindings for the Intercom API (https://api.intercom.io)
#
# == Basic Usage
# === Configure Intercom with your access credentials
#   Intercom.app_id = "my_app_id"
#   Intercom.secret_key = "my_secret_key"
# === Make requests to the API
#   Intercom::User.find(:email => "bob@example.com")
#
module Intercom
  @hostname = "api.intercom.io"
  @protocol = "https"
  @app_id = nil
  @secret_key = nil

  ##
  # Set the id of the application you want to interact with.
  # When logged into your intercom console, the app_id is in the url after /apps (eg http://intercom.io/apps/<app-id>)
  def self.app_id=(app_id)
    @app_id = app_id
  end

  ##
  # Set the secret key to gain access to your application data.
  # When logged into your intercom console, you can view/create api keys in the settings menu
  def self.secret_key=(secret_key)
    @secret_key = secret_key
  end


  private
  def self.url_for_path(path)
    raise ArgumentError, "You must set both Intercom.app_id and Intercom.secret_key to use this client. See https://github.com/intercom/intercom for usage examples." if [@app_id, @secret_key].any?(&:nil?)
    "#{protocol}://#{@app_id}:#{@secret_key}@#{hostname}/api/v1/#{path}"
  end

  def self.require_email_or_user_id(params)
    raise ArgumentError.new("Expected params Hash, got #{params.class}") unless params.is_a?(Hash)
    raise ArgumentError.new("Either email or user_id must be specified") unless params.keys.any? { |key| ["email", "user_id"].include?(key.to_s) }
  end

  def self.post(path, payload_hash)
    execute_request(:post, path, {}, {:content_type => :json, :accept => :json}, payload_hash)
  end

  def self.put(path, payload_hash)
    execute_request(:put, path, {}, {:content_type => :json, :accept => :json}, payload_hash)
  end

  def self.get(path, params)
    execute_request(:get, path, params)
  end

  def self.execute_request(method, path, params = {}, headers = {}, payload = nil)
    method.eql?(:get) ? require_email_or_user_id(params) : require_email_or_user_id(payload)
    url = url_for_path(path)
    args = {
        :method => method,
        :url => url,
        :headers => {:params => params}.merge(headers).merge(:accept => :json),
        :open_timeout => 10,
        :payload => payload.nil? ? nil : payload.to_json,
        :timeout => 30,
        :verify_ssl => OpenSSL::SSL::VERIFY_PEER,
        :ssl_ca_file => File.join(File.dirname(__FILE__), 'data/cacert.pem')
    }
    response = RestClient::Request.execute(args)
    JSON.parse(response.body)
  end

  def self.protocol #nodoc
    @protocol
  end

  def self.protocol=(override)
    @protocol = override
  end

  def self.hostname
    @hostname
  end

  def self.hostname=(override)
    @hostname = override
  end

  class IntercomObject #:nodoc:
    def initialize(attributes={})
      self.attributes = attributes
    end

    def attributes=(attributes={})
      @attributes = {}
      (attributes || {}).each do |key, value|
        self.send("#{key.to_s}=", value)
      end
    end

    def to_hash
      IntercomObject.for_wire(@attributes)
    end

    private

    def self.for_wire(object)
      return object.for_wire if object.respond_to?(:for_wire)
      return object.map { |item| for_wire(item) } if object.is_a?(Array)
      return object.inject({}) { |result, (k, value)| result[k] = for_wire(value); result } if object.is_a?(Hash)
      object
    end

    def method_missing(method, *args, &block)
      method_name = method.to_s
      if method_name.end_with?("=")
        attribute_name = method_name[0...-1]
        @attributes[attribute_name] = args[0]
        return
      else
        return @attributes[method_name] if @attributes.has_key?(method_name)
      end
      super
    end

    def self.standard_attributes(*attribute_names)
      attribute_names.each do |attribute_name|
        instance_eval do
          define_method attribute_name do
            @attributes[attribute_name.to_s]
          end
        end
      end
    end

    def self.requires_parameters(parameters, required)
      missing = Array(required) - parameters.keys.map(&:to_s)
      raise ArgumentError.new("Missing required parameters (#{missing.join(', ')}).") unless missing.empty?
    end

    def self.allows_parameters(parameters, allowed)
      complete_allowed = %W(email user_id) | Array(allowed)
      extra = parameters.keys.map(&:to_s) - complete_allowed
      raise ArgumentError.new("Unexpected parameters (#{extra.join(', ')}). Only allowed parameters for this operation are (#{complete_allowed.join(', ')}).") unless extra.empty?
    end

    def time_at(attribute_name)
      Time.at(@attributes[attribute_name]) if @attributes[attribute_name]
    end

    def set_time_at(attribute_name, time)
      @attributes[attribute_name.to_s] = time.to_i
    end
  end

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


  class ShallowHash < Hash #:nodoc:
    def []=(key, value)
      raise ArgumentError.new("custom_data does not support nested data structures (key: #{key}, value: #{value}") if value.is_a?(Array) || value.is_a?(Hash)
      super(key, value)
    end
  end

  ##
  # object representing a social profile for the User (see )http://docs.intercom.io/#SocialProfiles)
  class SocialProfile < IntercomObject
    def for_wire #:nodoc:
      @attributes
    end
  end

  ##
  # object representing a Message (+ any conversation on it) with a user
  class Message < IntercomObject

    ##
    # Finds a particular Message identified by thread_id
    def self.find(params)
      requires_parameters(params, %W(thread_id))
      Message.new(Intercom.get("messages", params))
    end

    ##
    # Finds all Messages to show a particular user
    def self.find_all(params)
      allows_parameters(params, [])
      response = Intercom.get("messages", params)
      response.map { |message| Message.new(message) }
    end

    ##
    # Either creates a new message from this user to your application admins, or a comment on an existing one
    def self.create(params)
      allows_parameters(params, %W(thread_id body))
      requires_parameters(params, %W(body))
      Message.new(Intercom.post("messages", params))
    end

    ##
    # Marks a message (identified by thread_id) as read
    def self.mark_as_read(params)
      requires_parameters(params, %W(thread_id))
      Message.new(Intercom.put("messages", {"read" => true}.merge(params)))
    end
  end

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