module Intercom
  module HashableObject
    def from_hash(hash)
      hash.each do |key,value|
        instance_variable_set("@#{key}".to_sym, value)
      end
    end

    def to_hash
      instance_variables.inject({}) do |hash, var|
        hash[var.to_s.delete("@").to_sym] = instance_variable_get(var)
        hash
      end
    end

    def displayable_attributes
      to_hash.delete_if {|k, v| !self.respond_to?(k) }
    end
  end
end