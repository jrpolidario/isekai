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

    attr_accessor :string, :x, :y, :color, :size
    attr_reader :font, :line_broken_strings_and_sizes

    after :string= do |arg|
      @string = @string.to_s

      @line_broken_strings_and_sizes = []
      @line_broken_strings_and_sizes = []

      @string.split("\n").map do |line_broken_string|
        line_broken_string = ' ' if line_broken_string == '' # prevent width size error
        line_broken_string_size = font.size_text(line_broken_string)

        @line_broken_strings_and_sizes << { string: line_broken_string, size: line_broken_string_size }
      end
    end

    def initialize(
      string: '',
      x:,
      y:,
      size: 16,
      color: [255, 255, 255],
      outline: nil, # i.e. { size: 2, r: 255, g: 255, b: 255, a: 255 },
      font_file_path:
    )
      self.string = string
      @x = x
      @y = y
      @size = size
      @color = evaluate_color(color)
      @outline = outline
      @font = Font.open(
        resolved_font_full_file_path(font_file_path), @size
      )
    end

    def draw
      @line_broken_strings_and_sizes.each.with_index do |line_broken_string_and_size, index|
        width = line_broken_string_and_size[:size][0]
        height = line_broken_string_and_size[:size][1]

        if @outline
          original_outline_size = @font.outline

          @font.outline = @outline[:size] || 0

          $app.sdl_renderer.copy(
            $app.sdl_renderer.create_texture_from(
              @font.render_blended(line_broken_string_and_size[:string], @outline.slice(:r, :g, :b, :a).values)
            ),
            nil,
            SDL2::Rect.new(@x, @y + (height * index), width, height)
          )

          @font.outline = original_outline_size
        end

        $app.sdl_renderer.copy(
          $app.sdl_renderer.create_texture_from(
            @font.render_blended(line_broken_string_and_size[:string], @color)
          ),
          nil,
          SDL2::Rect.new(@x, @y + (height * index), width, height)
        )
      end
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
