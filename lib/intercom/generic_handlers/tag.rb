require 'intercom/generic_handlers/base_handler'

module Intercom
  module GenericHandlers
    module Tag
      module ClassMethods
        def generic_tag(method_sym, *arguments, &block)

          handler_class = Class.new(GenericHandlers::BaseHandler) do
            def handle
              if method_string.start_with? 'tag_'
                return do_tagging
              elsif method_string.start_with? 'untag_'
                return do_untagging
              else
                raise_no_method_missing_handler
              end
            end

            private

            def do_tagging
              entity.create(:name => arguments[0], tagging_context.to_sym => tag_object_list(arguments))
            end

            def do_untagging
              current_tag = find_tag(arguments[0])
              return untag_via_save(current_tag) if current_tag
            end

            def find_tag(name_arg)
              Intercom::Tag.find(:name => name_arg)
            rescue Intercom::ResourceNotFound
              return nil # Ignore if tag has since been deleted
            end

            def untag_via_save(current_tag)
              current_tag.name = arguments[0]
              current_tag.send("#{untagging_context}=", untag_object_list(arguments))
              current_tag.save
            end
            
            def tag_object_list(args)
              args[1].map { |id| { :id => id } }
            end
            
            def untag_object_list(args)
              to_tag = tag_object_list(args)
              to_tag.map { |tag_object| tag_object[:untag] = true }
              to_tag
            end

            def tagging_context; method_string.gsub(/^tag_/, ''); end
            def untagging_context; method_string.gsub(/^untag_/, ''); end
          end

          handler_class.new(method_sym, arguments, self).handle
        end

      end

      def self.handles_method?(method_sym)
        method_sym.to_s.start_with?('tag_') || method_sym.to_s.start_with?('untag_')
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
