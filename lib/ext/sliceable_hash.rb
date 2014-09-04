class SliceableHash
 
  def initialize(hash)
    @hash = hash
  end

  # Return a hash that includes only the given keys.
  def slice(*keys)
    keys.map! { |key| @hash.convert_key(key) } if @hash.respond_to?(:convert_key, true)
    keys.each_with_object(@hash.class.new) { |k, hash| hash[k] = @hash[k] if @hash.has_key?(k) && if_string_not_empty(@hash[k]) }
  end
  
  def if_string_not_empty(val)
    val.kind_of?(String) ? !val.empty? : true
  end
end
