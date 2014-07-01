require 'intercom/generic_handlers/base_handler'

module Intercom
  module GenericHandlers
    module Count
      module ClassMethods
        def generic_count(method_sym, *arguments, &block)

          handler_class = Class.new(GenericHandlers::BaseHandler) do
            def handle
              match = method_string.match(GenericHandlers::Count.count_breakdown_matcher)
              if match && match[1] && match[2] && match[3].nil?
                do_broken_down_count(match[1], match[2])
              elsif method_string.end_with? '_count'
                return do_count
              else
                raise_no_method_missing_handler
              end
            end

            private

            def do_count
              entity.fetch_for_app.send(appwide_entity_to_count)['count']
            rescue Intercom::AttributeNotSetError
              # Indicates this this kind of counting is not supported
              raise_no_method_missing_handler
            end

            def do_broken_down_count(entity_to_count, count_context)
              result = entity.fetch_broken_down_count(entity_to_count, count_context)
              result.send(entity_to_count)[count_context]
            rescue Intercom::BadRequestError => ex
              # Indicates this this kind of counting is not supported
              ex.application_error_code == 'parameter_invalid' ? raise_no_method_missing_handler : raise
            end

            def appwide_entity_to_count; method_string.gsub(/_count$/, ''); end
          end

          handler_class.new(method_sym, arguments, self).handle
        end

      end

      def self.count_breakdown_matcher
        /([[:alnum:]]+)_counts_for_each_([[:alnum:]]+)/
      end

      def self.handles_method?(method_sym)
        method_sym.to_s.end_with? '_count' or method_sym.to_s.match(count_breakdown_matcher)
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
