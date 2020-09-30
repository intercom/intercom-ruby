# frozen_string_literal: true

require 'intercom/utils'
require 'intercom/base_collection_proxy'

module Intercom
  class ClientCollectionProxy < BaseCollectionProxy
    def each(&block)
      next_page = nil
      current_page = nil
      loop do
        response_hash = fetch(next_page)
        raise Intercom::HttpError, 'Http Error - No response entity returned' unless response_hash

        current_page = extract_current_page(response_hash)
        deserialize_response_hash(response_hash, block)
        next_page = extract_next_link(response_hash)
        break if next_page.nil? || (@params[:page] && (current_page >= @params[:page]))
      end
      self
    end

    def fetch(next_page)
      if next_page
        @client.get(next_page, {})
      else
        @client.get(@url, @params)
      end
    end

    private

    def paging_info_present?(response_hash)
      !!(response_hash['pages'])
    end

    def extract_next_link(response_hash)
      return nil unless paging_info_present?(response_hash)

      paging_info = response_hash.delete('pages')
      paging_info['next']
    end

    def extract_current_page(response_hash)
      return nil unless paging_info_present?(response_hash)

      response_hash['pages']['page']
    end
  end
end
