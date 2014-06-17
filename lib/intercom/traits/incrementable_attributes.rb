module Intercom
  module Traits
    module IncrementableAttributes

      def increment(key, value=1)
        mark_field_as_changed!(:increments)
        increments[key] ||= 0
        increments[key] += value
      end

      private

      def increments
        @increments ||= {}
      end

      def increments=(hash)
        mark_field_as_changed!(:increments)
        @increments = hash
      end
    end
  end
end
