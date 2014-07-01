module Intercom
  module Traits
    module IncrementableAttributes

      def increment(key, value=1)
        existing_value = self.custom_attributes[key]
        existing_value ||= 0
        self.custom_attributes[key] = existing_value + value
      end
    end
  end
end
