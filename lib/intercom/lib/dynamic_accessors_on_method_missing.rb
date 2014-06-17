module Intercom
  module Lib
    class DynamicAccessorsOnMethodMissing

      attr_reader :method_sym, :method_string, :arguments, :object, :klass

      def initialize(method_sym, *arguments, object)
        @method_sym = method_sym
        @method_string = method_sym.to_s
        @arguments = arguments
        @klass = object.class
        @object = object
      end

      def define_accessors_or_call(&block)
        return yield if not_an_accessor?
        if setter?
          Lib::DynamicAccessors.define_accessors(attribute_name, *arguments, object)
          object.send(method_sym, *arguments)
        else # getter
          if trying_to_access_private_variable?
            yield
          else
            raise Intercom::AttributeNotSetError, attribute_not_set_error_message
          end
        end
      end

      private

      def not_an_accessor?
        (method_string.end_with? '?') || (method_string.end_with? '!') || arguments.length > 1
      end

      def setter?
        method_string.end_with? '='
      end

      def attribute_name
        method_string.gsub(/=$/, '')
      end

      def trying_to_access_private_variable?
        object.instance_variable_defined?("@#{method_string}")
      end

      def attribute_not_set_error_message
        "'#{method_string}' called on #{klass} but it has not been set an " +
        "attribute or does not exist as a method"
      end
    end
  end
end
