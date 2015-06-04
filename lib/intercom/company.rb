require 'intercom/traits/incrementable_attributes'
require 'intercom/traits/api_resource'

module Intercom
  class Company
    include Traits::IncrementableAttributes
    include Traits::ApiResource

    def identity_vars ; [:id, :company_id] ; end
    def flat_store_attributes ; [:custom_attributes] ; end
    def update_verb ; 'post' ; end
  end
end
