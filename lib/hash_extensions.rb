Hash.class_eval do
  def dig_set(*nested_keys, with: value)
    current_key = nested_keys.first

    if nested_keys.size == 1
      self[current_key] = with
    else
      self[current_key] ||= {}
      self[current_key].dig_set(*nested_keys[1..-1], with: with)
    end
  end

  def dig_or_set(*nested_keys, with: value)
    current_key = nested_keys.first

    if nested_keys.size == 1
      self[current_key] = with unless has_key? current_key
      self[current_key]
    else
      self[current_key] ||= {}
      self[current_key].dig_or_set(*nested_keys[1..-1], with: with)
    end
  end

  # ref: https://stackoverflow.com/questions/17613426/flattening-nested-hash-to-an-array
  def deep_flatten(levels: nil)
    flat_map do |k, v|
      if v.is_a?(Hash) && (levels.nil? || levels > 0)
        [k, *v.deep_flatten]
      else
        [k, v]
      end
    end
  end

  def deep_map_values(levels: nil)
    flat_map do |k, v|
      if v.is_a?(Hash) && (levels.nil? || levels > 0)
        [*v.deep_map_values]
      else
        [v]
      end
    end
  end
end
