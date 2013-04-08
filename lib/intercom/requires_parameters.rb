module Intercom
  module RequiresParameters

    def requires_parameters(parameters, required)
      missing = Array(required) - parameters.keys.map(&:to_s)
      raise ArgumentError.new("Missing required parameters (#{missing.join(', ')}).") unless missing.empty?
    end

  end
end