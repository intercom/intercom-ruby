# frozen_string_literal: true

require 'intercom/utils'
require 'intercom/base_collection_proxy'

module Intercom
  class ScrollCollectionProxy < BaseCollectionProxy
    attr_reader :scroll_url, :scroll_param, :records

    def initialize(resource_name, resource_class, details: {}, client:)
      @resource_name = resource_name
      @resource_class = resource_class
      @scroll_url = (details[:url] || "/#{@resource_name}") + '/scroll'
      @client = client
    end

    def next(scroll_parameter = nil)
      @records = []
      response_hash = if !scroll_parameter
                        # First time so do initial get without scroll_param
                        @client.get(@scroll_url, '')
                      else
                        # Not first call so use get next page
                        @client.get(@scroll_url, scroll_param: scroll_parameter)
                      end
      raise Intercom::HttpError, 'Http Error - No response entity returned' unless response_hash

      @scroll_param = extract_scroll_param(response_hash)
      top_level_entity_key = entity_key_from_response(response_hash)
      response_hash[top_level_entity_key] = response_hash[top_level_entity_key].map do |object_json|
        Lib::TypedJsonDeserializer.new(object_json, @client).deserialize
      end
      @records = response_hash[@resource_name]
      self
    end

    def each(&block)
      scroll_param = nil
      loop do
        response_hash = if !scroll_param
                          @client.get(@scroll_url, '')
                        else
                          @client.get(@scroll_url, scroll_param: scroll_param)
                        end
        raise Intercom::HttpError, 'Http Error - No response entity returned' unless response_hash

        top_level_entity_key = entity_key_from_response(response_hash)
        response_hash[top_level_entity_key].each do |object_json|
          block.call Lib::TypedJsonDeserializer.new(object_json, @client).deserialize
        end
        scroll_param = extract_scroll_param(response_hash)
        break unless records_present?(response_hash)
      end
      self
    end

    private

    def entity_key_from_response(response_hash)
      top_level_type = response_hash['type']
      if resource_name == 'subscriptions'
        'items'
      else
        Utils.entity_key_from_type(top_level_type)
      end
    end

    def records_present?(response_hash)
      !response_hash[entity_key_from_response(response_hash)].empty?
    end

    def extract_scroll_param(response_hash)
      return nil unless records_present?(response_hash)

      response_hash['scroll_param']
    end
  end
end
