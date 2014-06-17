module Intercom
  module GenericHandlers
    class BaseHandler
      attr_reader :method_sym, :arguments, :entity

      def initialize(method_sym, arguments, entity)
        @method_sym = method_sym
        @arguments = arguments
        @entity = entity
      end

      def method_string
        method_sym.to_s
      end

      def raise_no_method_missing_handler
        raise Intercom::NoMethodMissingHandler, "Could not handle '#{method_string}'"
      end
    end

  end
end
