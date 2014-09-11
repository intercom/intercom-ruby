require 'intercom/api_operations/list'
require 'intercom/api_operations/find_all'
require 'intercom/api_operations/save'
require 'intercom/api_operations/delete'
require 'intercom/traits/api_resource'

module Intercom
  class Subscription
    include ApiOperations::List
    include ApiOperations::Find
    include ApiOperations::Save
    include ApiOperations::Delete
    include Traits::ApiResource
  end
end
