require 'intercom/traits/incrementable_attributes'
require 'intercom/traits/api_resource'

module Intercom
  class User
    include Traits::IncrementableAttributes
    include Traits::ApiResource

    def identity_vars ; [:id, :email, :user_id] ; end
    def flat_store_attributes ; [:custom_attributes] ; end
    def update_verb ; 'post' ; end

  end
end
