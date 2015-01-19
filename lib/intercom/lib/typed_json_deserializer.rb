module Intercom
  module Lib

      # Responsibility: To decide whether we are deserializing a collection or an
      # entity of a particular type and to dispatch deserialization
      class TypedJsonDeserializer
        attr_reader :json

        def initialize(json)
          @json = json
        end

        def deserialize
          if blank_object_type?(object_type)
            raise DeserializationError, "No type field was found to facilitate deserialization"
          elsif list_object_type?(object_type)
            deserialize_collection(json[object_entity_key])
          else # singular object type
            deserialize_object(json)
          end
        end

        private

        def blank_object_type?(object_type)
          object_type.nil? || object_type == ''
        end

        def list_object_type?(object_type)
          object_type.end_with?('.list')
        end

        def deserialize_collection(collection_json)
          return [] if collection_json == nil
          collection_json.map { |item_json| TypedJsonDeserializer.new(item_json).deserialize }
        end

        def deserialize_object(object_json)
          entity_class = Utils.constantize_singular_resource_name(object_entity_key)
          entity_class.from_api(object_json)
        end

        def object_type
          @object_type ||= json['type']
        end

        def object_entity_key
          @object_entity_key ||= Utils.entity_key_from_type(object_type)
        end

      end
  end
end
