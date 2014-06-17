module Intercom
  module ApiOperations
    module Count
      module ClassMethods
        def count
          singular_resource_name = Utils.resource_class_to_singular_name(self)
          Intercom::Count.send("#{singular_resource_name}_count")
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
