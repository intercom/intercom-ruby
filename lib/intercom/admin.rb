require 'intercom/api_operations/list'
require 'intercom/traits/api_resource'

module Intercom
  class Admin
    include ApiOperations::List
    include Traits::IncrementableAttributes
    include Traits::ApiResource
  end
end
