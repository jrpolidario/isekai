module Rubuild
  class Texture
    attr_accessor :sdl_texture
    singleton_class.attr_reader :cache

    @cache = {}

    def initialize(sdl_texture: nil)
      @sdl_texture = sdl_texture
    end

    def self.load(filename)
      texture = Texture.new

      self.cache[filename] ||= (
        # bitmap = SDL2::Surface.load(filename)
        # bitmap.color_key = bitmap.pixel(0, 0)
        # texture = $app.sdl_renderer.create_texture_from(bitmap)
        # bitmap.destroy
        # texture
        $app.sdl_renderer.load_texture(filename)
      )

      texture.sdl_texture = self.cache[filename]

      texture
    end

    def self.new_from_render(width:, height:)
      sdl_texture = $app.sdl_renderer.create_texture(
        SDL2::PixelFormat::RGBA8888,
        SDL2::Texture::ACCESS_TARGET,
        width,
        height
      )

      $app.sdl_renderer.render_target = sdl_texture
      $app.sdl_renderer.clear

    	yield

      $app.sdl_renderer.reset_render_target

      Texture.new(sdl_texture: sdl_texture)
    end

    def update_from_render
      $app.sdl_renderer.render_target = sdl_texture
      $app.sdl_renderer.clear

    	yield

      $app.sdl_renderer.reset_render_target
      self
    end

    # delegate

    def width
      sdl_texture.w
    end

    def width=(value)
      sdl_texture.w = value
    end

    def height
      sdl_texture.h
    end

    def height=(value)
      sdl_texture.h = value
    end
  end
end
