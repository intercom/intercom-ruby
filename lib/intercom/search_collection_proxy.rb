# frozen_string_literal: true

require 'intercom/utils'
require 'intercom/base_collection_proxy'

module Intercom
  class SearchCollectionProxy < BaseCollectionProxy
    def initialize(resource_name, resource_class, details: {}, client:)
      super(resource_name, resource_class, details: details, client: client, method: 'post')
    end

    private

    def payload
      payload = {
        query: @params[:query]
      }
      if sort_field || sort_order
        payload[:sort] = {}
        payload[:sort][:field] = sort_field if sort_field
        payload[:sort][:order] = sort_order if sort_order
      end
      if per_page || starting_after
        payload[:pagination] = {}
        payload[:pagination][:per_page] = per_page if per_page
        payload[:pagination][:starting_after] = starting_after if starting_after
      end
      payload
    end

    def sort_field
      @params[:sort_field]
    end

    def sort_order
      @params[:sort_order]
    end

    def per_page
      @params[:per_page]
    end

    def starting_after
      @params[:starting_after]
    end
  end
end
