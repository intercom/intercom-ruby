module Intercom
  module HashableObject
    def from_hash(hash)
      hash.each {|attribute, value| instance_variable_set("@#{attribute}".to_sym, value) }
    end

    def to_hash
      instance_variables.inject({}) do |hash, var|
        hash[var.to_s.delete("@").to_sym] = instance_variable_get(var)
        hash
      end
    end

    def displayable_attributes
      to_hash.select {|attribute, value| self.respond_to?(attribute) }
    end

    def to_wire
      to_hash.select {|attribute, value| self.respond_to?("#{attribute.to_s}=") }
    end
  end
end