module Intercom
  module UnixTimestampUnwrapper
    def time_at(attribute_name)
      Time.at(@attributes[attribute_name]) if @attributes[attribute_name]
    end

    def set_time_at(attribute_name, time)
      @attributes[attribute_name.to_s] = time.to_i
    end
  end
end