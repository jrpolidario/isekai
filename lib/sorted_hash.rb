module SortedHash
  class IntegerKeys < Hash
    # TODO: slow
    def []=(key, value)
      super
      new_sorted_hash = Hash[sort_by(&:first)]
      clear.merge! new_sorted_hash
    end
  end
end
