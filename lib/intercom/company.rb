require 'intercom/api_operations/count'
require 'intercom/api_operations/list'
require 'intercom/api_operations/find'
require 'intercom/api_operations/find_all'
require 'intercom/api_operations/save'
require 'intercom/api_operations/load'
require 'intercom/extended_api_operations/users'
require 'intercom/extended_api_operations/tags'
require 'intercom/traits/incrementable_attributes'
require 'intercom/traits/api_resource'

module Intercom
  class Company
    include ApiOperations::Count
    include ApiOperations::List
    include ApiOperations::Find
    include ApiOperations::FindAll
    include ApiOperations::Save
    include ApiOperations::Load
    include ExtendedApiOperations::Users
    include ExtendedApiOperations::Tags
    include Traits::IncrementableAttributes
    include Traits::ApiResource

    def identity_vars ; [:id, :company_id] ; end
    def flat_store_attributes ; [:custom_attributes] ; end
    def update_verb ; 'post' ; end
  end
end
