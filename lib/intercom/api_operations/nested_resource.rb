# frozen_string_literal: true

module Intercom
  module ApiOperations
    module NestedResource
      module ClassMethods
        def nested_resource_methods(resource,
                                    path: nil,
                                    operations: nil,
                                    resource_plural: nil)
          resource_plural ||= Utils.pluralize(resource.to_s)
          path ||= resource_plural
          raise ArgumentError, 'operations array required' if operations.nil?

          resource_url_method = :"#{resource_plural}_url"
          resource_name = Utils.resource_class_to_collection_name(self)
          define_method(resource_url_method.to_sym) do |id, nested_id = nil|
            url = "/#{resource_name}/#{id}/#{path}"
            url += "/#{nested_id}" unless nested_id.nil?
            url
          end

          operations.each do |operation|
            case operation
            when :create
              define_method(:"create_#{resource}") do |params|
                url = send(resource_url_method, self.id)
                response = client.post(url, params)
                raise_no_response_error unless response
                self.class.from_api(response)
              end
            when :add
              define_method(:"add_#{resource}") do |params|
                url = send(resource_url_method, self.id)
                response = client.post(url, params)
                raise_no_response_error unless response
                self.class.from_api(response)
              end
            when :delete
              define_method(:"remove_#{resource}") do |params|
                url = send(resource_url_method, self.id, params[:id])
                response = client.delete(url, params)
                raise_no_response_error unless response
                self.class.from_api(response)
              end
            when :list
              define_method(resource_plural.to_sym) do
                url = send(resource_url_method, self.id)
                resource_class = Utils.constantize_resource_name(resource.to_s)
                resource_class.collection_proxy_class.new(resource_plural, resource_class, details: { url: url }, client: client)
              end
            else
              raise ArgumentError, "Unknown operation: #{operation.inspect}"
            end
          end
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

      private def raise_no_response_error
        raise Intercom::HttpError, 'Http Error - No response entity returned'
      end
    end
  end
end
