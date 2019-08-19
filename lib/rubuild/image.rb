module Rubuild
  class Image
    attr_accessor :x, :y, :width, :height, :rotation, :texture

    def initialize(x: 0, y: 0, width:, height:, rotation: 0, file_path: nil, texture: nil, **remaining_args)
      @x = x
      @y = y
      @width = width
      @height = height
      @rotation = rotation
      @texture = evaluate_texture(file_path: file_path, texture: texture)
    end

    def draw
      # $app.sdl_renderer.copy(
      #   texture.sdl_texture,
      #   nil,
      #   SDL2::Rect[x, y, width, height]
      # )
      $app.sdl_renderer.copy_ex(
        texture.sdl_texture,
        nil, # source rect
        SDL2::Rect[x, y, width, height], # destination rect
        rotation,
        nil, # rotation anchor point: default is center of 3rd arg
        SDL2::Renderer::FLIP_NONE
      )
    end

    def draw
      # $app.sdl_renderer.copy(
      #   texture.sdl_texture,
      #   nil,
      #   SDL2::Rect[x, y, width, height]
      # )
      $app.sdl_renderer.copy_ex(
        texture.sdl_texture,
        nil, # source rect
        SDL2::Rect[x, y, width, height], # destination rect
        rotation,
        nil, # rotation anchor point: default is center of 3rd arg
        SDL2::Renderer::FLIP_NONE
      )
    end

    private

    def evaluate_texture(file_path: nil, texture: nil)
      raise ArgumentError, 'cannot pass in both `file_path` and `texture`' if file_path && texture

      if file_path
        Texture.load(
          resolved_image_full_file_path(file_path)
        )
      else
        texture
      end
    end

    def self.new_from_render(x: 0, y: 0, width:, height:)
      texture = Texture.new_from_render do
        yield
      end

      Image.new(
        x: x,
        y: y,
        width: width,
        height: height,
        texture: texture
      )
    end

    def resolved_image_full_file_path(file_path)
      return file_path if File.exist?(file_path)

      full_app_directory_shared_path = File.join(RUBUILD_PATH, 'app', 'images', 'shared', file_path)
      return full_app_directory_shared_path if File.exist? full_app_directory_shared_path

      app_directory_path = self.class.name.split('::').map(&:underscore)
      full_app_directory_path = File.join(RUBUILD_PATH, 'app', *app_directory_path, file_path)
      return full_app_directory_path if File.exist? full_app_directory_path

      raise ArgumentError, "file does not exist: #{full_app_directory_path}"
    end
  end
end
