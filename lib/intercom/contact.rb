require 'intercom/traits/api_resource'

module Intercom
  class Contact
    include Traits::ApiResource

    def identity_vars ; [:email, :user_id] ; end
    def flat_store_attributes ; [:custom_attributes] ; end
    def update_verb; 'put' ; end
  end
end
