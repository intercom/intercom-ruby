module Intercom
  module Traits
    module DataAttributeAccessors

      def attribute_value(data_attribute)
        if data_attribute.custom
          custom_attributes[data_attribute.name]
        elsif location_data_attribute?(data_attribute)
          location_data.send(data_attribute.name.to_sym)
        elsif avatar_attribute?(data_attribute)
          avatar.send(data_attribute.name.to_sym)
        elsif plan_attribute?(data_attribute)
          plan.send(data_attribute.name.to_sym)
        else
          send(data_attribute.name.to_sym)
        end
      rescue
        nil
      end

      private

      def location_data_attribute?(data_attribute)
        data_attribute.full_name.start_with?('location_data.')
      end

      def avatar_attribute?(data_attribute)
        data_attribute.full_name.start_with?('avatar.')
      end

      def plan_attribute?(data_attribute)
        data_attribute.full_name.start_with?('plan.')
      end
    end
  end
end