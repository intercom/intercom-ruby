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
          object.instance_eval %Q"
            def #{attribute}=(value)
              mark_field_as_changed!(:#{attribute})
              @#{attribute} = Intercom::Lib::FlatStore.new(value)
            end
            def #{attribute}
              @#{attribute}
            end
          "
        end

        def define_date_based_accessors(attribute, value, object)
          object.instance_eval %Q"
            def #{attribute}=(value)
              mark_field_as_changed!(:#{attribute})
              @#{attribute} = value.nil? ? nil : value.to_i
            end
            def #{attribute}
              @#{attribute}.nil? ? nil : Time.at(@#{attribute})
            end
          "
        end

        def define_standard_accessors(attribute, value, object)
            object.instance_eval %Q"
              def #{attribute}=(value)
                mark_field_as_changed!(:#{attribute})
                @#{attribute} = value
              end
              def #{attribute}
                @#{attribute}
              end
            "
        end

      end
    end
  end
end
