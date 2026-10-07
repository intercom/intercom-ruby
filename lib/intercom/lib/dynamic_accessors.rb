module Intercom
  module Lib
    module DynamicAccessors

      class << self

        def define_accessors(attribute, value, object)
          if attribute.to_s.end_with?('_at') && attribute.to_s != 'update_last_request_at'
            define_date_based_accessors(attribute, value, object)
          elsif object.flat_store_attribute?(attribute)
            define_flat_store_based_accessors(attribute, value, object)
          else
            define_standard_accessors(attribute, value, object)
          end
        end

        private

        def define_flat_store_based_accessors(attribute, value, object)
          ivar = ivar_name(attribute, object)
          object.singleton_class.class_eval do
            define_method("#{attribute}=") do |val|
              mark_field_as_changed!(attribute.to_sym)
              instance_variable_set(ivar, Intercom::Lib::FlatStore.new(val))
            end
            define_method(attribute) { instance_variable_get(ivar) }
          end
        end

        def define_date_based_accessors(attribute, value, object)
          ivar = ivar_name(attribute, object)
          object.singleton_class.class_eval do
            define_method("#{attribute}=") do |val|
              mark_field_as_changed!(attribute.to_sym)
              instance_variable_set(ivar, val.nil? ? nil : val.to_i)
            end
            define_method(attribute) do
              time = instance_variable_get(ivar)
              time.nil? ? nil : Time.at(time)
            end
          end
        end

        def define_standard_accessors(attribute, value, object)
          ivar = ivar_name(attribute, object)
          object.singleton_class.class_eval do
            define_method("#{attribute}=") do |val|
              mark_field_as_changed!(attribute.to_sym)
              instance_variable_set(ivar, val)
            end
            define_method(attribute) { instance_variable_get(ivar) }
          end
        end

        # Keys such as "pt-BR" are not valid identifiers, so normalise them for the ivar name.
        def ivar_name(attribute, object)
          ivar = "@#{attribute.to_s.gsub(/\W/, '_')}"
          object.register_attribute_key(ivar, attribute) if ivar != "@#{attribute}"
          ivar
        end

      end
    end
  end
end
