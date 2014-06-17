require 'intercom/api_operations/save'
require 'intercom/traits/api_resource'

module Intercom
  class Message
    include ApiOperations::Save
    include Traits::ApiResource
  end
end
