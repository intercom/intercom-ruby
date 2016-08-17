require "intercom/utils"
require "ext/sliceable_hash"

module Intercom
  class ScrollCollectionProxy

    attr_reader :resource_name, :scroll_url, :resource_class

    def initialize(resource_name, finder_details: {}, client:)
      @resource_name = resource_name
      @resource_class = Utils.constantize_resource_name(resource_name)
      @scroll_url = (finder_details[:url] || "/#{@resource_name}")
      @client = client
    end

    def each(&block)
      scroll_param = nil
      scroll_url = @scroll_url + '/scroll'
      loop do
        if not scroll_param
          response_hash = @client.get(scroll_url, '')
        else
          response_hash = @client.get(scroll_url, scroll_param: scroll_param)
        end
        raise Intercom::HttpError.new('Http Error - No response entity returned') unless response_hash
        deserialize_response_hash(response_hash, block)
        scroll_param = extract_scroll_param(response_hash)
        break if not users_present?(response_hash)
      end
      self
    end

    def [](target_index)
      self.each_with_index do |item, index|
        return item if index == target_index
      end
      nil
    end

    include Enumerable

    private

    def deserialize_response_hash(response_hash, block)
      top_level_type = response_hash.delete('type')
      if resource_name == 'subscriptions'
        top_level_entity_key = 'items'
      else
        top_level_entity_key = Utils.entity_key_from_type(top_level_type)
      end
      response_hash[top_level_entity_key].each do |object_json|
        block.call Lib::TypedJsonDeserializer.new(object_json).deserialize
      end
    end

    def users_present?(response_hash)
      (response_hash['users'].length > 0)
    end

    def extract_scroll_param(response_hash)
      return nil unless users_present?(response_hash)
      response_hash['scroll_param']
    end
  end
end
