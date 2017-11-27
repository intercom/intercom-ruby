require 'intercom/traits/api_resource'
require 'intercom/traits/data_attribute_accessors'

module Intercom
  class Contact
    include Traits::ApiResource
    include Traits::DataAttributeAccessors

    def identity_vars ; [:email, :user_id] ; end
    def flat_store_attributes ; [:custom_attributes] ; end
    def update_verb; 'put' ; end
  end
end
