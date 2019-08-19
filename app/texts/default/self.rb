module Texts
  class Default < Base
    def initialize(**args)
      super(
        font_file_path: 'Open_Sans/OpenSans-Regular.ttf', **args
      )
    end
  end
end
