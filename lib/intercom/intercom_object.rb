module Intercom
  class IntercomObject #:nodoc:
    def initialize(attributes={})
      self.attributes = attributes
    end

    def to_hash
      IntercomObject.for_wire(@attributes)
    end

    private

    def attributes=(attributes={})
      @attributes = {}
      (attributes || {}).each do |key, value|
        self.send("#{key.to_s}=", value)
      end
    end

    def self.for_wire(object)
      return object.for_wire if object.respond_to?(:for_wire)
      return object.map { |item| for_wire(item) } if object.is_a?(Array)
      return object.inject({}) { |result, (k, value)| result[k] = for_wire(value); result } if object.is_a?(Hash)
      object
    end

    def method_missing(method, *args, &block)
      method_name = method.to_s
      if method_name.end_with?("=")
        attribute_name = method_name[0...-1]
        @attributes[attribute_name] = args[0]
        return
      else
        return @attributes[method_name] if @attributes.has_key?(method_name)
      end
      super
    end

    def self.standard_attributes(*attribute_names)
      attribute_names.each do |attribute_name|
        instance_eval do
          define_method attribute_name do
            @attributes[attribute_name.to_s]
          end
        end
      end
    end

    def self.requires_parameters(parameters, required)
      missing = Array(required) - parameters.keys.map(&:to_s)
      raise ArgumentError.new("Missing required parameters (#{missing.join(', ')}).") unless missing.empty?
    end

    def self.allows_parameters(parameters, allowed)
      complete_allowed = %W(email user_id) | Array(allowed)
      extra = parameters.keys.map(&:to_s) - complete_allowed
      raise ArgumentError.new("Unexpected parameters (#{extra.join(', ')}). Only allowed parameters for this operation are (#{complete_allowed.join(', ')}).") unless extra.empty?
    end

    def time_at(attribute_name)
      Time.at(@attributes[attribute_name]) if @attributes[attribute_name]
    end

    def set_time_at(attribute_name, time)
      @attributes[attribute_name.to_s] = time.to_i
    end
  end
end