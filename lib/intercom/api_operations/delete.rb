# frozen_string_literal: true

require 'intercom/utils'

module Intercom
  module ApiOperations
    module Delete
      def delete(object)
        @client.delete("/#{collection_name}/#{object.id}", {})
        object
      end

      alias_method 'archive', 'delete'
    end
  end
end
