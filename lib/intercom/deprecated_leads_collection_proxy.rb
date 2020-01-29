# frozen_string_literal: true

module Intercom
  class DeprecatedLeadsCollectionProxy < ClientCollectionProxy
    def fetch(next_page)
      response_hash = if next_page
                        @client.get(next_page, {})
                      else
                        @client.get(@url, @params)
                      end
      transform(response_hash)
    end

    def transform(response_hash)
      response_hash['type'] = 'lead.list'
      leads_list = response_hash.delete('contacts')
      leads_list.each { |lead| lead['type'] = 'lead' }
      response_hash['leads'] = leads_list
      response_hash
    end
  end
end
