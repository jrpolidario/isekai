Object.class_eval do
  def memoized!(*identifier)
    memoized = (
      instance_variable_get(:@memoized) ||
        instance_variable_set(:@memoized, {})
    )
    memoized[identifier] = yield unless memoized.has_key? identifier
    memoized[identifier]
  end

  def memoized_with_object!(*identifier, &block)
    memoized = (
      instance_variable_get(:@memoized) ||
        instance_variable_set(:@memoized, {})
    )
    memoized[identifier] = instance_exec(&block) unless memoized.has_key? identifier
    memoized[identifier]
  end
end
