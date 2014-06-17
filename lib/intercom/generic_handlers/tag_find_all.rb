require 'intercom/generic_handlers/base_handler'

module Intercom
  module GenericHandlers
    module TagFindAll
      module ClassMethods
        def generic_tag_find_all(method_sym, *arguments, &block)

          handler_class = Class.new(GenericHandlers::BaseHandler) do
            def handle
              if method_string.start_with? 'find_all_for_'
                return do_tag_find_all
              else
                raise_no_method_missing_handler
              end
            end

            private

            def do_tag_find_all
              Intercom::Tag.find_all(cleaned_arguments.merge(:taggable_type => Utils.singularize(context)))
            end

            def cleaned_arguments
              cleaned_args = arguments[0]
              cleaned_args[:taggable_id] = cleaned_args.delete(:id) if cleaned_args.has_key?(:id)
              cleaned_args
            end

            def context; method_string.gsub(/^find_all_for_/, ''); end
          end

          handler_class.new(method_sym, arguments, self).handle
        end

      end

      def self.handles_method?(method_sym)
        method_sym.to_s.start_with? 'find_all_for_'
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
