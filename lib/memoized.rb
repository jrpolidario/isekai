Object.class_eval do
  def memoized!(*identifier, &block)
    # begin
    #   instance_variable_get(:@memoized).fetch(identifier)
    # rescue NoMethodError => e
    #   if e.message.include? "undefined method `fetch' for nil"
    #     memoized = { identifier => yield }
    #     instance_variable_set(:@memoized, memoized)
    #     memoized[identifier]
    #   else
    #     raise
    #   end
    # rescue KeyError => e
    #   if e.message.include? 'key not found'
    #     binding.pry
    #     memoized = instance_variable_get(:@memoized)
    #     memoized[identifier] = yield
    #     memoized[identifier]
    #   else
    #     raise
    #   end
    # end
    memoized = (
      instance_variable_get(:@memoized) ||
        instance_variable_set(:@memoized, {})
    )

    memoized[identifier] = yield unless memoized.has_key? identifier
    memoized[identifier]
  end

  def rememoized!(*identifier, &block)
    memoized = (
      instance_variable_get(:@memoized) ||
        instance_variable_set(:@memoized, {})
    )

    memoized[identifier] = yield
  end

  def memoized_with_object!(*identifier, &block)
    memoized = (
      instance_variable_get(:@memoized) ||
        instance_variable_set(:@memoized, {})
    )
    memoized[identifier] = instance_exec(&block) unless memoized.has_key? identifier
    memoized[identifier]
  end

  def unmemoized!(*identifier)
    memoized = (
      instance_variable_get(:@memoized) ||
        instance_variable_set(:@memoized, {})
    )
    memoized.delete(identifier)
  end
end
