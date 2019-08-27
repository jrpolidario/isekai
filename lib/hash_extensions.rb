Hash.class_eval do
  def dig_set(*nested_keys, with: value)
    current_key = nested_keys.first

    if nested_keys.size == 1
      self[current_key] = with
    else
      self[current_key] ||= SortedHash::IntegerKeys.new
      self[current_key].dig_set(*nested_keys[1..-1], with: with)
    end
  end

  def dig_or_set(*nested_keys, with: value)
    current_key = nested_keys.first

    if nested_keys.size == 1
      self[current_key] = with unless has_key? current_key
      self[current_key]
    else
      self[current_key] ||= SortedHash::IntegerKeys.new
      self[current_key].dig_or_set(*nested_keys[1..-1], with: with)
    end
  end
end
