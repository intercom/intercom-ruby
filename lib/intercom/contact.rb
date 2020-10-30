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
    nested_resource_methods :segment, operations: %i[list]

    def self.collection_proxy_class
      Intercom::BaseCollectionProxy
    end

    def identity_vars
      [:id]
    end

    def flat_store_attributes
      [:custom_attributes]
    end
  end
end
