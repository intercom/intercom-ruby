module Intercom
  module HashableObject
    def from_hash(hash)
      hash.each do |key,value|
        setter_method = "#{key.to_s}="
        self.send(setter_method, value) if self.respond_to?(setter_method)
      end
    end

    def to_hash
      instance_variables.inject({}) do |hash, var|
        hash[var.to_s.delete("@").to_sym] = instance_variable_get(var)
        hash
      end
    end
  end
end