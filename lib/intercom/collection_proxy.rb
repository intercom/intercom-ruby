require "intercom/utils"
require "ext/hash"

module Intercom
  class CollectionProxy

    attr_reader :resource_name

    def initialize(resource_name, finder_details = {})
      @resource_name = resource_name
      @resource_class = Utils.constantize_resource_name(resource_name)
      @finder_url = (finder_details[:url] || "/#{@resource_name}")
      @finder_params = (finder_details[:params] || {})
    end

    def each(&block)
      next_page = nil
      loop do
        if next_page
          response_hash = Intercom.get(next_page, {})
        else
          response_hash = Intercom.get(@finder_url, @finder_params)
        end
        deserialize_response_hash(response_hash, block)
        next_page = extract_next_link(response_hash)
        break if next_page.nil?
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

    def count
      raise NoMethodError, "undefined method `count' for #{self.class}. Consider using the dedicated Intercom::Count interface if suitable"
    end

    private

    def resource_class; @resource_class; end

    def deserialize_response_hash(response_hash, block)
      top_level_type = response_hash.delete('type')
      top_level_entity_key = Utils.entity_key_from_type(top_level_type)
      response_hash[top_level_entity_key].each do |object_json|
        block.call Lib::TypedJsonDeserializer.new(object_json).deserialize
      end
    end

    def paging_info_present?(response_hash)
      !!(response_hash['pages'] && response_hash['pages']['type'])
    end

    def extract_next_link(response_hash)
      return nil unless paging_info_present?(response_hash)
      paging_info = response_hash.delete('pages')
      paging_info["next"]
    end
  end
end
