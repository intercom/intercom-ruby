require 'intercom/traits/api_resource'

module Intercom
  class DataAttribute
    include Traits::ApiResource

    def update_verb; 'put' ; end
  end
end
