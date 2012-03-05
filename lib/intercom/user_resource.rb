require 'intercom/unix_timestamp_unwrapper'

module Intercom
  class UserResource
    include UnixTimestampUnwrapper

    def initialize(attributes={})
      self.attributes = attributes
    end

    def to_hash
      UserResource.for_wire(@attributes)
    end

    def email
      @attributes["email"]
    end

    def email=(email)
      @attributes["email"]=email
    end

    def user_id
      @attributes["user_id"]
    end

    def user_id=(user_id)
      @attributes["user_id"] = user_id
    end

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