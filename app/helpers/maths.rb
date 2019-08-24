module Helpers
  class Maths
    class << self
      def to_2_5d(x, y, z)
        [x, (y / 2.0) + (z / 2.0)]
      end
    end
  end
end
