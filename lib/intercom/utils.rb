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

      def resource_class_to_singular_name(resource_class)
        resource_class.to_s.split('::')[-1].downcase
      end

      def resource_class_to_collection_name(resource_class)
        Utils.pluralize(resource_class_to_singular_name(resource_class))
      end

      def constantize_resource_name(resource_name)
        class_name = Utils.singularize(resource_name.capitalize)
        define_lightweight_class(class_name) unless Intercom.const_defined?(class_name)
        namespaced_class_name = "Intercom::#{class_name}"
        Object.const_get(namespaced_class_name)
      end

      def constantize_singular_resource_name(resource_name)
        class_name = resource_name.split('_').map(&:capitalize).join
        define_lightweight_class(class_name) unless Intercom.const_defined?(class_name)
        namespaced_class_name = "Intercom::#{class_name}"
        Object.const_get(namespaced_class_name )
      end

      def define_lightweight_class(class_name)
        #File.open('./intercom_ruby_dynamically_defined_classes.log', 'a') {|f| f.puts("Dynamically defining the class Intercom::#{class_name}") } #HACK
        new_class_definition = Class.new(Object) do
          include Traits::ApiResource
        end
        Intercom.const_set(class_name, new_class_definition)
      end

      def entity_key_from_type(type)
        is_list = type.split('.')[1] == 'list'
        entity_name = type.split('.')[0]
        is_list ?  Utils.pluralize(entity_name) : entity_name
      end
    end
  end
end
