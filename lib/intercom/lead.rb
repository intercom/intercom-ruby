# frozen_string_literal: true

require 'intercom/traits/api_resource'

module Intercom
  class Lead
    include Traits::ApiResource

    def identity_vars
      %i[email user_id]
    end

    def flat_store_attributes
      [:custom_attributes]
    end

    def update_verb
      'put'
    end
  end
end
