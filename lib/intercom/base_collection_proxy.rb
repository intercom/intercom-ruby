# frozen_string_literal: true

require 'intercom/utils'

module Intercom
  class BaseCollectionProxy
    attr_reader :resource_name, :url, :resource_class

    def initialize(resource_name, resource_class, details: {}, client:, method: 'get')
      @resource_name = resource_name
      @resource_class = resource_class
      @url = (details[:url] || "/#{@resource_name}")
      @params = (details[:params] || {})
      @client = client
      @method = method
    end

    def each(&block)
      loop do
        response_hash = @client.public_send(@method, @url, payload)
        raise Intercom::HttpError, 'Http Error - No response entity returned' unless response_hash

        deserialize_response_hash(response_hash, block)
        break unless has_next_link?(response_hash)
      end
      self
    end

    def [](target_index)
      each_with_index do |item, index|
        return item if index == target_index
      end
      nil
    end

    include Enumerable

    private

    def deserialize_response_hash(response_hash, block)
      top_level_type = response_hash.delete('type')
      top_level_entity_key = if resource_name == 'subscriptions'
                               'items'
                             else
                               Utils.entity_key_from_type(top_level_type)
                             end
      response_hash[top_level_entity_key].each do |object_json|
        if top_level_type == 'event.summary'
          block.call Lib::TypedJsonDeserializer.new(object_json, @client, top_level_type).deserialize
        else
          block.call Lib::TypedJsonDeserializer.new(object_json, @client).deserialize
        end
      end
    end

    def has_next_link?(response_hash)
      paging_info = response_hash.delete('pages')
      return false unless paging_info

      paging_next = paging_info['next']
      if paging_next
        @params[:starting_after] = paging_next['starting_after']
        return true
      else
        @params[:starting_after] = nil
        return false
      end
    end

    def payload
      @params.keep_if { |k, v| !v.nil? }.to_h
    end
  end
end
