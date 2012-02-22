require "intercom/version"
require "rest_client"
require 'json'

module Intercom
  @hostname = "api.intercom.io"
  @protocol = "https"
  @app_id = nil
  @secret_key = nil

  def self.app_id=(app_id)
    @app_id = app_id
  end

  def self.secret_key=(secret_key)
    @secret_key = secret_key
  end

  def self.protocol
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
        :timeout => 30
    }
    response = RestClient::Request.execute(args)
    JSON.parse(response.body)
  end

  class IntercomObject
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

    def self.for_wire(object)
      return object.for_wire if object.respond_to?(:for_wire)
      return object.map { |item| for_wire(item) } if object.is_a?(Array)
      return object.inject({}) { |result, (k, values)| result[k] = for_wire(values); result } if object.is_a?(Hash)
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

    def autovivifying_hash
      Hash.new { |ht, k| ht[k] = autovivifying_hash }
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

    def self.time_attributes(*attribute_names)
      attribute_names.each do |attribute_name|
        instance_eval do
          define_method attribute_name do
            Time.at(@attributes[attribute_name.to_s]) if @attributes[attribute_name.to_s]
          end
          define_method "#{attribute_name}=" do |time|
            @attributes[attribute_name.to_s] = time.to_i
          end
        end
      end
    end
  end

  class User < IntercomObject
    time_attributes :created_at, :last_impression_at
    standard_attributes :email, :user_id, :name, :session_count

    def self.find(params)
      response = Intercom.get("users", params)
      User.new(response)
    end

    def self.create(params)
      User.new(params).save
    end

    def save
      response = Intercom.post("users", to_hash)
      self.attributes=(response)
      self
    end

    def social_accounts=(social_accounts)
      @attributes["social_accounts"] = social_accounts.map { |account| SocialAccount.new(account) }
    end

    def social_accounts
      @attributes["social_accounts"] ||= []
    end

    def custom_data
      @attributes["custom_data"] ||= autovivifying_hash
    end

    def location_data
      @attributes["location_data"] ||= autovivifying_hash
    end
  end

  class SocialAccount < IntercomObject
    def for_wire
      @attributes
    end
  end

  class Message < IntercomObject
    def self.find(params)
      Message.new(Intercom.get("messages", params))
    end

    def self.find_all(params)
      response = Intercom.get("messages", params)
      response.map { |message| Message.new(message) }
    end

    def self.create(params)
      Message.new(Intercom.post("messages", params))
    end

    def self.mark_as_read(params)
      Message.new(Intercom.put("messages", {"read" => true}.merge(params)))
    end
  end
  class Impression < IntercomObject
    def self.create(params)
      Impression.new(Intercom.post("impressions", params))
    end
  end
end