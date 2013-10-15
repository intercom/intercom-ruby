require "intercom/version"
require "intercom/user_resource"
require "intercom/user"
require "intercom/message_thread"
require "intercom/impression"
require "intercom/note"
require "intercom/tag"
require "intercom/request"
require "json"

##
# Intercom is a customer relationship management and messaging tool for web app owners
#
# This library provides ruby bindings for the Intercom API (https://api.intercom.io)
#
# == Basic Usage
# === Configure Intercom with your access credentials
#   Intercom.app_id = "my_app_id"
#   Intercom.api_key = "my_api_key"
# === Make requests to the API
#   Intercom::User.find(:email => "bob@example.com")
#
module Intercom
  @hostname = "api.intercom.io"
  @protocol = "https"
  @endpoints = nil
  @current_endpoint = nil
  @app_id = nil
  @api_key = nil

  ##
  # Set the id of the application you want to interact with.
  # When logged into your intercom console, the app_id is in the url after /apps (eg https://www.intercom.io/apps/<app-id>)
  # @param [String] app_id
  # @return [String]
  def self.app_id=(app_id)
    @app_id = app_id
  end

  def self.app_id
    @app_id
  end

  ##
  # Set the api key to gain access to your application data.
  # When logged into your intercom console, you can view/create api keys in the settings menu
  # @param [String] api_key
  # @return [String]
  def self.api_key=(api_key)
    @api_key = api_key
  end

  def self.api_key
    @api_key
  end

  private

  def self.target_base_url
    raise ArgumentError, "You must set both Intercom.app_id and Intercom.api_key to use this client. See https://github.com/intercom/intercom-ruby for usage examples." if [@app_id, @api_key].any?(&:nil?)
    basic_auth_part = "#{@app_id}:#{@api_key}@"
    current_endpoint.gsub(/(https?:\/\/)(.*)/, "\\1#{basic_auth_part}\\2")
  end

  def self.send_request_to_path(request)
    request.execute(target_base_url)
  rescue Intercom::ServiceUnavailableError => e
    if endpoints.length > 1
      retry_on_alternative_endpoint(request)
    else
      raise e
    end
  end

  def self.retry_on_alternative_endpoint(request)
    @current_endpoint = alternative_random_endpoint
    request.execute(target_base_url)
  end

  def self.current_endpoint
    return @current_endpoint if @current_endpoint && @endpoint_randomized_at > (Time.now - (60 * 5))
    @endpoint_randomized_at = Time.now
    @current_endpoint = random_endpoint
  end

  def self.random_endpoint
    endpoints.shuffle.first
  end

  def self.alternative_random_endpoint
    (endpoints.shuffle - [@current_endpoint]).first
  end

  def self.post(path, payload_hash)
    send_request_to_path(Intercom::Request.post(path, payload_hash))
  end

  def self.delete(path, payload_hash)
    send_request_to_path(Intercom::Request.delete(path, payload_hash))
  end

  def self.put(path, payload_hash)
    send_request_to_path(Intercom::Request.put(path, payload_hash))
  end

  def self.get(path, params)
    send_request_to_path(Intercom::Request.get(path, params))
  end

  def self.check_required_params(params, path=nil) #nodoc
    return if path.eql?("users")
    raise ArgumentError.new("Expected params Hash, got #{params.class}") unless params.is_a?(Hash)
    raise ArgumentError.new("Either email or user_id must be specified") unless params.keys.any? { |key| %W(email user_id).include?(key.to_s) }
  end

  def self.protocol #nodoc
    @protocol
  end

  def self.protocol=(override) #nodoc
    @protocol = override
  end

  def self.hostname #nodoc
    @hostname
  end

  def self.hostname=(override) #nodoc
    @hostname = override
  end

  def self.endpoint=(endpoint) #nodoc
    self.endpoints = [endpoint]
    @current_endpoint = nil
  end

  def self.endpoints=(endpoints) #nodoc
    @endpoints = endpoints
    @current_endpoint = nil
  end

  def self.endpoints
    @endpoints || ["#{@protocol}://#{hostname}"]
  end

  # Raised when the credentials you provide don't match a valid account on Intercom.
  # Check that you have set <b>Intercom.app_id=</b> and <b>Intercom.api_key=</b> correctly.
  class AuthenticationError < StandardError;
  end

  # Raised when something does wrong on within the Intercom API service.
  class ServerError < StandardError;
  end

  # Raised when we have bad gateway errors.
  class BadGatewayError < StandardError;
  end

  # Raised when we reach socket connect timeout
  class ServiceUnavailableError < StandardError;
  end

  # Raised when requesting resources on behalf of a user that doesn't exist in your application on Intercom.
  class ResourceNotFound < StandardError;
  end
end