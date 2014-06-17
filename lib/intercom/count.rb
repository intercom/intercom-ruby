require 'intercom/traits/api_resource'
require 'intercom/api_operations/find'
require 'intercom/traits/generic_handler_binding'
require 'intercom/generic_handlers/count'

module Intercom
  class Count
    include ApiOperations::Find
    include Traits::ApiResource
    include Traits::GenericHandlerBinding
    include GenericHandlers::Count

    def self.fetch_for_app
      Intercom::Count.find({})
    end

    def self.fetch_broken_down_count(entity_to_count, count_context)
      Intercom::Count.find(:type => entity_to_count, :count => count_context)
    end
  end
end
