module Intercom
  class ShallowHash < Hash #:nodoc:
    def []=(key, value)
      raise ArgumentError.new("custom_data does not support nested data structures (key: #{key}, value: #{value}") if value.is_a?(Array) || value.is_a?(Hash)
      super(key, value)
    end
  end
end
