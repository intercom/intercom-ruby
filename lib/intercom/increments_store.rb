module Intercom
  # Sub-class of {FlatStore} for storing increments.
  # Requires {Numeric} values.
  class IncrementsStore < FlatStore
    private
    def validate_key_and_value(key, value)
      raise ArgumentError.new("Value must be Numeric: #{value}") unless value.is_a?(Numeric)
      super
    end
  end
end
