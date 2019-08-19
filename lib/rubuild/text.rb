module Rubuild
  class Text
    module Font
      @cache = {}

      def self.open(file_path, size)
        @cache[[file_path, size]] ||= (
          SDL2::TTF.open(file_path, size)
        )
      end
    end

    include SuperCallbacks

    COLOR_MAPPINGS = {
      black: [0, 0, 0],
      white: [255, 255, 255],
      red: [255, 0, 0],
      green: [0, 255, 0],
      blue: [0, 0, 255]
    }

    attr_accessor :string, :x, :y, :width, :height, :font

    after :string= do |arg|
      self.width, self.height = font.size_text(@string)
    end

    def initialize(
      string: '',
      x:,
      y:,
      color: [255, 255, 255],
      size: 16,
      font_file_path:
    )
      @string = string
      @x = x
      @y = y
      @color = color
      @size = size
      @color = evaluate_color(color)
      @font = Font.open(
        resolved_font_full_file_path(font_file_path), @size
      )
      @width, @height = @font.size_text(@string)
    end

    def draw
      $app.sdl_renderer.copy(
        $app.sdl_renderer.create_texture_from(
          @font.render_solid(@string, @color)
        ),
        nil,
        SDL2::Rect.new(@x, @y, @width, @height)
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

    def resolved_font_full_file_path(file_path)
      return file_path if File.exist?(file_path)

      full_app_directory_shared_path = File.join(RUBUILD_PATH, 'app', 'texts', 'shared', file_path)
      return full_app_directory_shared_path if File.exist? full_app_directory_shared_path

      app_directory_path = self.class.name.split('::').map(&:underscore)
      full_app_directory_path = File.join(RUBUILD_PATH, 'app', *app_directory_path, file_path)
      return full_app_directory_path if File.exist? full_app_directory_path

      raise ArgumentError, "file does not exist: #{full_app_directory_path}"
    end
  end
end
