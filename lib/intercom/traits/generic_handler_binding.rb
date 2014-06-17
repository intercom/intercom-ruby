module Intercom
  module Traits

    # Allows us to have one class level method missing handler across all entities
    # which can dispatch to the appropriate function based on the method name
    module GenericHandlerBinding

      module ClassMethods
        def method_missing(method_sym, *arguments, &block)
          if respond_to? :generic_tag and GenericHandlers::Tag.handles_method?(method_sym)
            return generic_tag(method_sym, *arguments, block)
          elsif respond_to? :generic_tag_find_all and GenericHandlers::TagFindAll.handles_method?(method_sym)
            return generic_tag_find_all(method_sym, *arguments, block)
          elsif respond_to? :generic_count and GenericHandlers::Count.handles_method?(method_sym)
            return generic_count(method_sym, *arguments, block)
          end
          super
        rescue Intercom::NoMethodMissingHandler
          super
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

    end
  end
end
