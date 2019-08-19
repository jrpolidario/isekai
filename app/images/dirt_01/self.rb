module Images
  class Dirt < Base
    include SuperCallbacks

    attr_accessor :dirt_cache

    def initialize(**args)
      super(
        file_path: 'dirt_01.png', **args
      )
    end
  end
end
