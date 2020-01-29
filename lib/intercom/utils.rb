# frozen_string_literal: true

module Intercom
  module Utils
    class << self
      def singularize(str)
        str.gsub(/ies$/, 'y').gsub(/s$/, '')
      end

      def pluralize(str)
        return str.gsub(/y$/, 'ies') if str =~ /y$/

        "#{str}s"
      end

      # the constantize method that exists in rails to allow for ruby 1.9 to get namespaced constants
      def constantize(camel_cased_word)
        names = camel_cased_word.split('::')
        names.shift if names.empty? || names.first.empty?

        constant = Object
        names.each do |name|
          constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
        end
        constant
      end

      def resource_class_to_singular_name(resource_class)
        resource_name = resource_class.to_s.split('::')[-1]
        resource_name = maybe_underscore_name(resource_name)
        resource_name.downcase
      end

      def maybe_underscore_name(resource_name)
        resource_name.gsub!(/(.)([A-Z])/, '\1_\2') || resource_name
      end

      def resource_class_to_collection_name(resource_class)
        Utils.pluralize(resource_class_to_singular_name(resource_class))
      end

      def constantize_resource_name(resource_name)
        class_name = Utils.singularize(resource_name.capitalize)
        define_lightweight_class(class_name) unless Intercom.const_defined?(class_name, false)
        namespaced_class_name = "Intercom::#{class_name}"
        constantize namespaced_class_name
      end

      def constantize_singular_resource_name(resource_name)
        class_name = resource_name.split('_').map(&:capitalize).join
        define_lightweight_class(class_name) unless Intercom.const_defined?(class_name, false)
        namespaced_class_name = "Intercom::#{class_name}"
        constantize namespaced_class_name
      end

      def define_lightweight_class(class_name)
        new_class_definition = Class.new(Object) do
          include Traits::ApiResource
        end
        Intercom.const_set(class_name, new_class_definition)
      end

      def entity_key_from_type(type)
        return 'data' if type == 'list'

        is_list = type.split('.')[1] == 'list'
        entity_name = type.split('.')[0]
        is_list ? Utils.pluralize(entity_name) : entity_name
      end
    end
  end
end
