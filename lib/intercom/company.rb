require 'intercom/traits/incrementable_attributes'
require 'intercom/traits/api_resource'
require 'intercom/traits/data_attribute_accessors'

module Intercom
  class Company
    include Traits::IncrementableAttributes
    include Traits::ApiResource
    include Traits::DataAttributeAccessors

    def identity_vars ; [:id, :company_id] ; end
    def flat_store_attributes ; [:custom_attributes] ; end
    def update_verb ; 'post' ; end
  end
end
