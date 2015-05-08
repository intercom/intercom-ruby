require 'intercom/api_operations/count'
require 'intercom/api_operations/load'
require 'intercom/api_operations/find'
require 'intercom/api_operations/find_all'
require 'intercom/api_operations/save'
require 'intercom/api_operations/convert'
require 'intercom/traits/api_resource'

module Intercom
  class Contact
    include ApiOperations::Load
    include ApiOperations::Find
    include ApiOperations::FindAll
    include ApiOperations::Save
    include ApiOperations::Convert
    include Traits::ApiResource

    def identity_vars ; [:email, :user_id] ; end
    def flat_store_attributes ; [:custom_attributes] ; end
    def update_verb; 'put' ; end
  end
end
