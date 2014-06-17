require 'intercom/api_operations/count'
require 'intercom/api_operations/find'
require 'intercom/api_operations/save'
require 'intercom/traits/api_resource'

module Intercom
  class Segment
    include ApiOperations::List
    include ApiOperations::Find
    include ApiOperations::Save
    include ApiOperations::Count
    include Traits::ApiResource
  end
end
