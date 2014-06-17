require 'set'

module Intercom
  module Traits
    module DirtyTracking

      def reset_changed_fields!
        @changed_fields = Set.new
      end

      def mark_fields_as_changed!(field_names)
        @changed_fields ||= Set.new
        field_names.each do |attr|
          @changed_fields.add(attr.to_s)
        end
      end

      def mark_field_as_changed!(field_name)
        @changed_fields ||= Set.new
        @changed_fields.add(field_name.to_s)
      end

      def field_changed?(field_name)
        @changed_fields ||= Set.new
        @changed_fields.include?(field_name.to_s)
      end

      def instance_variables_excluding_dirty_tracking_field
        instance_variables.reject{|var| var == :@changed_fields}
      end
    end
  end
end
