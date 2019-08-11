class Text
  module Font
    DEFAULT_FONT_FILE_PATH = 'fonts/Open_Sans/OpenSans-Regular.ttf'.freeze

    @cache = {}

    def self.open(file_path, size)
      @cache[[file_path, size]] ||= (
        SDL2::TTF.open(file_path, size)
      )
    end
  end

  COLOR_MAPPINGS = {
    black: [0, 0, 0],
    white: [255, 255, 255],
    red: [255, 0, 0],
    green: [0, 255, 0],
    blue: [0, 0, 255]
  }

  attr_accessor :string, :x, :y, :width, :height, :font_file_path, :font

  def initialize(
    string:,
    x:,
    y:,
    color: [255, 255, 255],
    size: 16,
    font_file_path: Font::DEFAULT_FONT_FILE_PATH
  )
    # set all arguments into instance variables
    method(__method__).parameters.map do |_, name|
      instance_variable_set(
        "@#{name}",
        binding.local_variable_get(name)
      )
    end

    @color = evaluate_color(color)
    @font = Font.open(@font_file_path, @size)
    @width, @height = @font.size_text(@string)
  end

  def draw
    $app.sdl_renderer.copy(
      $app.sdl_renderer.create_texture_from(
        @font.render_solid(
          @string, @color
        )
      ),
      nil,
      SDL2::Rect.new(
        @x,
        @y,
        @width,
        @height
      )
    )
  end

  private

  def evaluate_color(color_symbol_or_array)
    case color_symbol_or_array
    when Array
      color_symbol_or_array
    when String, Symbol
      COLOR_MAPPINGS.fetch(color_symbol_or_array.to_sym)
    else raise TypeError, "expected `#{color_symbol_or_array}` to be String, Symbol, or Array, but is #{color_symbol_or_array.class}"
    end
  end
end
