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
    "#{protocol}://#{@app_id}:#{@secret_key}@#{hostname}/v1/#{path}"
  end

  def self.execute_request(method, path, params = {}, headers = {}, payload = nil)
    url = url_for_path(path)
    args = {
        :method => method,
        :url => url,
        :headers => {:params => params}.merge(headers),
        :open_timeout => 10,
        :payload => payload,
        :timeout => 30
    }
    RestClient::Request.execute(args)
  end

  class IntercomObject
    def initialize(attributes={})
      @attributes = {}
      attributes.each do |key, value|
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

    def auto_array_hash
      Hash.new { |hash, key| hash[key] = [] }
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
      response = Intercom.execute_request(:get, "users", params)
      User.new(response)
    end

    def self.create(params)
      User.new(params).save
    end

    def save
      Intercom.execute_request(:post, "users", {}, {:content_type => :json}, to_hash.to_json)
      self
    end

    def social_accounts=(social_accounts)
      social_accounts ||= {}
      @attributes["social_accounts"] = social_accounts.inject(auto_array_hash) do |new_hash, (service, accounts)|
        new_hash[service] = accounts.map { |account_hash| SocialAccount.new(account_hash) }
        new_hash
      end
    end

    def social_accounts
      @attributes["social_accounts"] ||= auto_array_hash()
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
end
