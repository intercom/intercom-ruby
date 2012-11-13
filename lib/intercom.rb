require "intercom/version"
require "intercom/user_resource"
require "intercom/user"
require "intercom/message_thread"
require "intercom/impression"
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

  ##
  # Set the api key to gain access to your application data.
  # When logged into your intercom console, you can view/create api keys in the settings menu
  # @param [String] api_key
  # @return [String]
  def self.api_key=(api_key)
    @api_key = api_key
  end

  private
  def self.url_for_path(path)
    raise ArgumentError, "You must set both Intercom.app_id and Intercom.api_key to use this client. See https://github.com/intercom/intercom for usage examples." if [@app_id, @api_key].any?(&:nil?)
    "#{protocol}://#{@app_id}:#{@api_key}@#{hostname}/v1/#{path}"
  end

  def self.post(path, payload_hash)
    Intercom::Request.post(url_for_path(path), payload_hash).execute
  end

  def self.delete(path, payload_hash)
    Intercom::Request.delete(url_for_path(path), payload_hash).execute
  end

  def self.put(path, payload_hash)
    Intercom::Request.put(url_for_path(path), payload_hash).execute
  end

  def self.get(path, params)
    Intercom::Request.get(url_for_path(path), params).execute
  end

  def self.check_required_params(params, path=nil)
    return if path.eql?("users")
    raise ArgumentError.new("Expected params Hash, got #{params.class}") unless params.is_a?(Hash)
    raise ArgumentError.new("Either email or user_id must be specified") unless params.keys.any? { |key| %W(email user_id).include?(key.to_s) }
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

  # Raised when the credentials you provide don't match a valid account on Intercom.
  # Check that you have set <b>Intercom.app_id=</b> and <b>Intercom.api_key=</b> correctly.
  class AuthenticationError < StandardError;
  end

  # Raised when something does wrong on within the Intercom API service.
  class ServerError < StandardError;
  end

  # Raised when requesting resources on behalf of a user that doesn't exist in your application on Intercom.
  class ResourceNotFound < StandardError;
  end
end