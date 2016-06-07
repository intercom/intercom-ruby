require 'intercom/client_collection_proxy'

module Intercom
  class ClientScrollCollectionProxy < Intercom::ClientCollectionProxy
    def each(&block)
      loop do
        response_hash = @client.get(@finder_url, @finder_params)
        raise Intercom::HttpError.new('Http Error - No response entity returned') unless response_hash
        if deserialize_response_hash(response_hash, block)
          @finder_params[:scroll_param] = extract_next_link(response_hash)
        else
          break
        end
      end
      self
    end

    protected

    def deserialize_response_hash(response_hash, block)
      top_level_type = response_hash.delete('type')
      if resource_name == 'subscriptions'
        top_level_entity_key = 'items'
      else
        top_level_entity_key = Utils.entity_key_from_type(top_level_type)
      end

      return false if response_hash[top_level_entity_key].size.zero?

      response_hash[top_level_entity_key].each do |object_json|
        block.call Lib::TypedJsonDeserializer.new(object_json).deserialize
      end
      true
    end

    def extract_next_link(response_hash)
      response_hash["scroll_param"]
    end
  end
end
