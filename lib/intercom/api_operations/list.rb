require 'intercom/collection_proxy'

module Intercom
  module ApiOperations
    module List # TODO: Should we rename to All
      module ClassMethods
        def all
          CollectionProxy.new(Utils.resource_class_to_collection_name(self))
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
