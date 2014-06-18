require 'intercom/extended_api_operations/reply'
require 'intercom/api_operations/find_all'
require 'intercom/api_operations/find'
require 'intercom/api_operations/load'
require 'intercom/api_operations/save'
require 'intercom/traits/api_resource'

module Intercom
  class Conversation
    include ExtendedApiOperations::Reply
    include ApiOperations::FindAll
    include ApiOperations::Find
    include ApiOperations::Load
    include ApiOperations::Save
    include Traits::ApiResource
  end
end
