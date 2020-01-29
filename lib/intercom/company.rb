require 'intercom/traits/incrementable_attributes'
require 'intercom/traits/api_resource'
require 'intercom/api_operations/nested_resource'

module Intercom
  class Company
    include Traits::IncrementableAttributes
    include Traits::ApiResource
    include ApiOperations::NestedResource

    nested_resource_methods :contact, operations: %i[list]

    def self.collection_proxy_class
      Intercom::ClientCollectionProxy
    end

    def identity_vars ; [:id, :company_id] ; end
    def flat_store_attributes ; [:custom_attributes] ; end
    def update_verb ; 'post' ; end
  end
end
