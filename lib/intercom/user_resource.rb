require 'intercom/unix_timestamp_unwrapper'

module Intercom
  # Base class for resources tied off a {User}, all of which are scoped by either the users :email or :user_id.
  class UserResource
    include UnixTimestampUnwrapper

    def initialize(attributes={})
      self.attributes = attributes
    end

    # @return [Hash] hash of all the attributes in the structure they will be sent to the api
    def to_hash
      UserResource.for_wire(@attributes)
    end

    # @return [String] email address
    def email
      @attributes["email"]
    end

    # @param [String] email
    # @return [String]
    def email=(email)
      @attributes["email"] = email
    end


    # @return [String] user_id
    def user_id
      @attributes["user_id"]
    end

    # @param [String] user_id
    # @return [String]
    def user_id=(user_id)
      @attributes["user_id"] = user_id
    end

    # updates the internal state of this {UserResource} based on the response from the API
    # @return [UserResource] self
    def update_from_api_response(api_response)
      api_response.each do |key, value|
        setter_method = "#{key.to_s}="
        if self.respond_to?(setter_method)
          self.send(setter_method, value)
        else
          @attributes[key.to_s] = value
        end
      end
      self
    end

    private

    def attributes=(attributes={})
      @attributes = {}
      (attributes || {}).each do |key, value|
        self.send("#{key.to_s}=", value)
      end
    end

    def self.for_wire(object)
      return object.for_wire if object.respond_to?(:for_wire)
      return object.map { |item| for_wire(item) } if object.is_a?(Array)
      return object.inject({}) { |result, (k, value)| result[k] = for_wire(value); result } if object.is_a?(Hash)
      object
    end

    def self.from_api(api_response)
      obj = self.new
      obj.update_from_api_response(api_response)
    end

    def method_missing(method, *args, &block)
      return @attributes[method.to_s] if @attributes.has_key?(method.to_s)
      super
    end

    def self.requires_parameters(parameters, required)
      missing = Array(required) - parameters.keys.map(&:to_s)
      raise ArgumentError.new("Missing required parameters (#{missing.join(', ')}).") unless missing.empty?
    end

  end
end