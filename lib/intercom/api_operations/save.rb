# frozen_string_literal: true

require 'intercom/utils'
require 'ext/sliceable_hash'

module Intercom
  module ApiOperations
    module Save
      PARAMS_NOT_PROVIDED = Object.new
      private_constant :PARAMS_NOT_PROVIDED

      def create(params = PARAMS_NOT_PROVIDED)
        if collection_class.ancestors.include?(Intercom::Lead) && params == PARAMS_NOT_PROVIDED
          params = {}
        elsif params == PARAMS_NOT_PROVIDED
          raise ArgumentError, '.create requires 1 parameter'
        end

        instance = collection_class.new(params)
        instance.mark_fields_as_changed!(params.keys)
        save(instance)
      end

      def save(object)
        if id_present?(object) && !posted_updates?(object)
          response = @client.put("/#{collection_name}/#{object.id}", object.to_submittable_hash)
        else
          response = @client.post("/#{collection_name}", object.to_submittable_hash.merge(identity_hash(object)))
        end
        object.from_response(response) if response # may be nil we received back a 202
      end

      def identity_hash(object)
        object.respond_to?(:identity_vars) ? SliceableHash.new(object.to_hash).slice(*object.identity_vars.map(&:to_s)) : {}
      end

      private

      def id_present?(object)
        object.id && object.id.to_s != ''
      end

      def posted_updates?(object)
        object.respond_to?(:update_verb) && object.update_verb == 'post'
      end
    end
  end
end
