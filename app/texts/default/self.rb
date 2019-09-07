module Texts
  class Default < Base
    def initialize(**args)
      # super(
      #   font_file_path: 'Open_Sans/OpenSans-Regular.ttf', **args
      # )
      # super(
      #   font_file_path: 'Press_Start_2P/PressStart2P-Regular.ttf', **args
      # )
      super(
        font_file_path: 'Montserrat/Montserrat-Bold.ttf',
        # outline: { size: 1, r: 0, g: 0, b: 0, a: 128 }, # THIS IS SO SLOW!!!
        **args
      )
    end
  end
end
