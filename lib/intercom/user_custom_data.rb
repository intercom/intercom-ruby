module Intercom
  # Sub-class of {Hash} for storing custom data attributes.
  # Doesn't allow nested Hashes or Arrays. And requires {String} or {Symbol} keys.
  class UserCustomData < Hash
    def initialize(attributes={})
      (attributes).each do |key, value|
        validate_key_and_value(key, value)
        self[key] = value
      end
    end

    def []=(key, value)
      validate_key_and_value(key, value)
      super(key.to_s, value)
    end

    def [](key)
      super(key.to_s)
    end

    private
    def validate_key_and_value(key, value)
      raise ArgumentError.new("custom_data does not support nested data structures (key: #{key}, value: #{value}") if value.is_a?(Array) || value.is_a?(Hash)
      raise ArgumentError.new("custom_data key must be String or Symbol: #{key}") unless key.is_a?(String) || key.is_a?(Symbol)
    end
  end
end
