require 'intercom/lib/flat_store'
require 'intercom/lib/dynamic_accessors'
require 'intercom/lib/dynamic_accessors_on_method_missing'
require 'intercom/traits/dirty_tracking'
require 'intercom/lib/typed_json_deserializer'

module Intercom
  module Traits

    module ApiResource
      include DirtyTracking

      attr_accessor :id

      def initialize(attributes = {})
        from_hash(attributes)
      end

      def from_response(response)
        from_hash(response)
        reset_changed_fields!
        self
      end

      def from_hash(hash)
        hash.each do |attribute, value|
          next if type_field?(attribute)
          initialize_property(attribute, value)
        end
        initialize_missing_flat_store_attributes if respond_to? :flat_store_attributes
        self
      end

      def to_hash
        instance_variables_excluding_dirty_tracking_field.inject({}) do |hash, variable|
          hash[variable.to_s.delete("@")] = instance_variable_get(variable)
          hash
        end
      end

      def to_submittable_hash
        submittable_hash = {}
        to_hash.each do |attribute, value|
          submittable_hash[attribute] = value if submittable_attribute?(attribute, value)
        end
        submittable_hash
      end

      def method_missing(method_sym, *arguments, &block)
        Lib::DynamicAccessorsOnMethodMissing.new(method_sym, *arguments, self).
          define_accessors_or_call { super }
      end

      def flat_store_attribute?(attribute)
        (respond_to?(:flat_store_attributes)) && (flat_store_attributes.map(&:to_s).include?(attribute.to_s))
      end

      private

      def initialize_property(attribute, value)
        Lib::DynamicAccessors.define_accessors(attribute, value, self) unless accessors_already_defined?(attribute)
        set_property(attribute, value)
      end

      def accessors_already_defined?(attribute)
        respond_to?(attribute) && respond_to?("#{attribute}=")
      end

      def set_property(attribute, value)
        if typed_property?(attribute, value)
          value_to_set = Intercom::Lib::TypedJsonDeserializer.new(value).deserialize
        elsif flat_store_attribute?(attribute)
          value_to_set = Intercom::Lib::FlatStore.new(value)
        else
          value_to_set = value
        end
        call_setter_for_attribute(attribute, value_to_set)
      end

      def custom_attribute_field?(attribute)
        attribute == 'custom_attributes'
      end
      
      def message_from_field?(attribute, value)
        attribute.to_s == 'from' && value.is_a?(Hash) && value['type']
      end
      
      def message_to_field?(attribute, value)
        attribute.to_s == 'to' && value.is_a?(Hash) && value['type']
      end

      def typed_property?(attribute, value)
        typed_value?(value) &&
          !custom_attribute_field?(attribute) &&
          !message_from_field?(attribute, value) &&
          !message_to_field?(attribute, value) &&
          attribute != 'metadata'
      end

      def typed_value?(value)
        value.is_a? Hash and !!value['type']
      end

      def call_setter_for_attribute(attribute, value)
        setter_method = "#{attribute.to_s}="
        self.send(setter_method, value)
      end

      def type_field?(attribute)
        attribute == 'type'
      end

      def initialize_missing_flat_store_attributes
        flat_store_attributes.each do |attribute|
          unless instance_variables_excluding_dirty_tracking_field.map(&:to_s).include? "@#{attribute}"
            initialize_property(attribute, {})
          end
        end
      end

      def submittable_attribute?(attribute, value)
        # FlatStores always submitted, even if not changed, as we don't track their dirtyness
        value.is_a?(Intercom::Lib::FlatStore) || field_changed?(attribute)
      end

      module ClassMethods
        def from_api(api_response)
          object = self.new
          object.from_response(api_response)
          object
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

    end
  end
end
