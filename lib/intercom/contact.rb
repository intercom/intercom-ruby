# frozen_string_literal: true

require 'intercom/traits/incrementable_attributes'
require 'intercom/traits/api_resource'
require 'intercom/api_operations/nested_resource'

module Intercom
  class Contact
    include Traits::IncrementableAttributes
    include Traits::ApiResource
    include ApiOperations::NestedResource

    nested_resource_methods :tag, operations: %i[add delete list]
    nested_resource_methods :note, operations: %i[create list]
    nested_resource_methods :company, operations: %i[add delete list]

    def self.collection_proxy_class
      Intercom::BaseCollectionProxy
    end

    def identity_vars
      [:id]
    end

    def flat_store_attributes
      [:custom_attributes]
    end

    def archive
      response = @client.post("/contacts/#{self.id}/archive", {})
      raise Intercom::HttpError, 'Http Error - No response entity returned' unless response
      self.class.from_api(response)
    end

    def unarchive
      response = @client.post("/contacts/#{self.id}/unarchive", {})
      raise Intercom::HttpError, 'Http Error - No response entity returned' unless response
      self.class.from_api(response)
    end
  end
end
