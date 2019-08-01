require "intercom/utils"

module Intercom
  class SearchCollectionProxy

    attr_reader :resource_name, :resource_class

    def initialize(resource_name, search_details: {}, client:)
      @resource_name = resource_name
      @resource_class = Utils.constantize_resource_name(resource_name)
      @search_url = search_details[:url]
      @search_params = search_details[:params]
      @client = client
    end

    def each(&block)
      loop do
        response_hash = @client.post(@search_url, payload)
        raise Intercom::HttpError.new('Http Error - No response entity returned') unless response_hash
        deserialize_response_hash(response_hash, block)
        break unless has_next_link?(response_hash)
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
      top_level_entity_key = Utils.entity_key_from_type(top_level_type)
      response_hash[top_level_entity_key].each do |object_json|
        block.call Lib::TypedJsonDeserializer.new(object_json).deserialize
      end
    end

    def has_next_link?(response_hash)
      paging_info = response_hash.delete('pages')
      paging_next = paging_info["next"]
      if paging_next
        @search_params[:starting_after] = paging_next["starting_after"]
        return true
      else
        return false
      end
    end

    def payload
      payload = {
        query: @search_params[:query]
      }
      if @search_params[:sort_field] || @search_params[:sort_order]
        payload[:sort] = {}
        if @search_params[:sort_field]
          payload[:sort][:field] = @search_params[:sort_field]
        end
        if @search_params[:sort_order]
          payload[:sort][:order] = @search_params[:sort_order]
        end
      end
      if @search_params[:per_page] || @search_params[:starting_after]
        payload[:pagination] = {}
        if @search_params[:per_page]
          payload[:pagination][:per_page] = @search_params[:per_page]
        end
        if @search_params[:starting_after]
          payload[:pagination][:starting_after] = @search_params[:starting_after]
        end
      end
      return payload
    end

  end
end
