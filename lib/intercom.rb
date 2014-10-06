require "intercom/version"
require "intercom/user"
require "intercom/company"
require "intercom/note"
require "intercom/tag"
require "intercom/segment"
require "intercom/event"
require "intercom/conversation"
require "intercom/message"
require "intercom/admin"
require "intercom/count"
require "intercom/request"
require "intercom/subscription"
require "intercom/notification"
require "intercom/utils"
require "intercom/errors"
require "json"

##
# Intercom is a customer relationship management and messaging tool for web app owners
#
# This library provides ruby bindings for the Intercom API (https://api.intercom.io)
#
# == Basic Usage
# === Configure Intercom with your access credentials
#   Intercom.app_id = "my_app_id"
#   Intercom.app_api_key = "my_api_key"
# === Make requests to the API
#   Intercom::User.find(:email => "bob@example.com")
#
module Intercom
  @hostname = "api.intercom.io"
  @protocol = "https"

  def self.app_id=(app_id)
    Thread.current[:intercom_app_id] = app_id
  end

  def self.app_id
    Thread.current[:intercom_app_id]
  end

  def self.app_api_key=(app_api_key)
    Thread.current[:intercom_app_api_key] = app_api_key
  end

  def self.app_api_key
    Thread.current[:intercom_app_api_key]
  end

  # This method is obsolete and used to warn of backwards incompatible changes on upgrading
  def self.api_key=(val)
    raise ArgumentError, "#{compatibility_warning_text} #{compatibility_workaround_text} #{related_docs_text}"
  end

  private

  def self.target_base_url
    raise ArgumentError, "#{configuration_required_text} #{related_docs_text}" if [app_id, app_api_key].any?(&:nil?)
    basic_auth_part = "#{app_id}:#{app_api_key}@"
    current_endpoint.gsub(/(https?:\/\/)(.*)/, "\\1#{basic_auth_part}\\2")
  end

  def self.related_docs_text
    "See https://github.com/intercom/intercom-ruby for usage examples."
  end

  def self.compatibility_warning_text
    "It looks like you are upgrading from an older version of the intercom-ruby gem. Please note that this new version (#{Intercom::VERSION}) is not backwards compatible. "
  end

  def self.compatibility_workaround_text
    "To get rid of this error please set Intercom.app_api_key and don't set Intercom.api_key."
  end

  def self.configuration_required_text
    "You must set both Intercom.app_id and Intercom.app_api_key to use this client."
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
    Thread.current[:intercom_current_endpoint] = alternative_random_endpoint
    request.execute(target_base_url)
  end

  def self.current_endpoint
    current_endpoint = Thread.current[:intercom_current_endpoint]
    return current_endpoint if current_endpoint && endpoint_randomized_at > (Time.now - (60 * 5))
    self.endpoint_randomized_at = Time.now
    Thread.current[:intercom_current_endpoint] = random_endpoint
  end

  def self.endpoint_randomized_at
    Thread.current[:intercom_endpoint_randomized_at]
  end

  def self.endpoint_randomized_at=(time)
    Thread.current[:intercom_endpoint_randomized_at] = time
  end

  def self.random_endpoint
    endpoints.shuffle.first
  end

  def self.alternative_random_endpoint
    (endpoints.shuffle - [Thread.current[:intercom_current_endpoint]]).first
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
    Thread.current[:intercom_protocol] ||= @protocol
  end

  def self.protocol=(override) #nodoc
    Thread.current[:intercom_protocol] = override
  end

  def self.hostname #nodoc
    Thread.current[:intercom_hostname] ||= @hostname
  end

  def self.hostname=(override) #nodoc
    Thread.current[:intercom_hostname] = override
  end

  def self.endpoint=(endpoint) #nodoc
    self.endpoints = [endpoint]
    Thread.current[:intercom_current_endpoint] = nil
  end

  def self.endpoints=(endpoints) #nodoc
    Thread.current[:intercom_endpoints] = endpoints
    Thread.current[:intercom_current_endpoint] = nil
  end

  def self.endpoints
    Thread.current[:intercom_endpoints] ||= ["#{protocol}://#{hostname}"]
  end
end
