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
end
