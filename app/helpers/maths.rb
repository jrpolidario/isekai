module Helpers
  class Maths
    class << self
      def to_2_5d(x, y, z)
        [x, (y / 2) + (z / 2)]
      end
    end
  end
end
