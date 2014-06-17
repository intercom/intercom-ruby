require 'intercom/api_operations/count'
require 'intercom/api_operations/save'
require 'intercom/api_operations/list'
require 'intercom/api_operations/find'
require 'intercom/api_operations/find_all'
require 'intercom/traits/api_resource'
require 'intercom/traits/generic_handler_binding'
require 'intercom/generic_handlers/tag'
require 'intercom/generic_handlers/tag_find_all'

module Intercom
  class Tag
    include ApiOperations::Count
    include ApiOperations::Save
    include ApiOperations::List
    include ApiOperations::Find
    include ApiOperations::FindAll
    include Traits::ApiResource
    include Traits::GenericHandlerBinding
    include GenericHandlers::Tag
    include GenericHandlers::TagFindAll
  end
end
