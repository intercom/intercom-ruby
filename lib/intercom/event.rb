require 'intercom/traits/api_resource'

module Intercom
  class Event
    include Traits::ApiResource
    def update_verb; 'post' ; end
  end
end
