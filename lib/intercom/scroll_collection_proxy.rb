require "intercom/utils"
require "ext/sliceable_hash"

module Intercom
  class ScrollCollectionProxy

    attr_reader :resource_name, :scroll_url, :resource_class, :scroll_param, :users

    def initialize(resource_name, finder_details: {}, client:)
      @resource_name = resource_name
      @resource_class = Utils.constantize_resource_name(resource_name)
      @scroll_url = (finder_details[:url] || "/#{@resource_name}") + '/scroll'
      @client = client

    end

    def next(scroll_paramater=nil)
      @users = []
      if not scroll_paramater
        #First time so do initial get without scroll_param
        response_hash = @client.get(@scroll_url, '')
      else
        #Not first call so use get next page
        response_hash = @client.get(@scroll_url, scroll_param: scroll_paramater)
      end
      raise Intercom::HttpError.new('Http Error - No response entity returned') unless response_hash
      @scroll_param = extract_scroll_param(response_hash)
      top_level_entity_key = deserialize_response_hash(response_hash)
      response_hash[top_level_entity_key] = response_hash[top_level_entity_key].map do |object_json|
        Lib::TypedJsonDeserializer.new(object_json).deserialize
      end
      @users = response_hash['users']
      self
    end

    def each(&block)
      scroll_param = nil
      loop do
        if not scroll_param
          response_hash = @client.get(@scroll_url, '')
        else
          response_hash = @client.get(@scroll_url, scroll_param: scroll_param)
        end
        raise Intercom::HttpError.new('Http Error - No response entity returned') unless response_hash
        response_hash[deserialize_response_hash(response_hash)].each do |object_json|
          block.call Lib::TypedJsonDeserializer.new(object_json).deserialize
        end
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

    def deserialize_response_hash(response_hash)
      top_level_type = response_hash.delete('type')
      if resource_name == 'subscriptions'
        top_level_entity_key = 'items'
      else
        top_level_entity_key = Utils.entity_key_from_type(top_level_type)
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