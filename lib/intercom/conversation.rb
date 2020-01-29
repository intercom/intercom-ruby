require 'intercom/traits/api_resource'
require 'intercom/api_operations/nested_resource'

module Intercom
  class Conversation
    include Traits::ApiResource
    include ApiOperations::NestedResource

    nested_resource_methods :tag, operations: %i[add delete]
  end
end
