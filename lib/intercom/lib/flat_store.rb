module Intercom
  module Lib

    # Sub-class of {Hash} for storing custom data attributes.
    # Doesn't allow Arrays. And requires {String} or {Symbol} keys.
    class FlatStore < Hash

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

      def to_submittable_hash
        # Filter out Custom Object references when submitting to API
        self.reject do |key, value|
          value.is_a?(Hash)
        end
      end

      private
      def validate_key_and_value(key, value)
        raise ArgumentError.new("This does not support nested data structures (key: #{key}, value: #{value}") if value.is_a?(Array)
        raise ArgumentError.new("Key must be String or Symbol: #{key}") unless key.is_a?(String) || key.is_a?(Symbol)
      end
    end
  end
end
