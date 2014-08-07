require 'intercom/traits/api_resource'

module Intercom
  module ApiOperations
    module Save

      module ClassMethods
        def create(params)
          instance = self.new(params)
          instance.mark_fields_as_changed!(params.keys)
          instance.save
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

      def save
        collection_name = Utils.resource_class_to_collection_name(self.class)
        if id_present? && !posted_updates?
          response = Intercom.put("/#{collection_name}/#{id}", to_submittable_hash)
        else
          response = Intercom.post("/#{collection_name}", to_submittable_hash.merge(identity_hash))
        end
        from_response(response) if response # may be nil we received back a 202
      end

      private

      def id_present?
        id && id.to_s != ''
      end

      def posted_updates?
        respond_to?(:update_verb) && update_verb == 'post'
      end

      def identity_hash
        if respond_to?(:identity_vars) && attributes = to_hash
          (attributes.keys & identity_vars.map(&:to_s)).inject({}) do |sliced, attribute|
            sliced[attribute] = attributes[attribute]
            sliced
          end
        else
          {}
        end
      end
    end
  end
end
