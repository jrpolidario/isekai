class Image
  attr_accessor :x, :y, :width, :height, :texture

  def initialize(x:, y:, width:, height:, file_path: nil, texture: nil)
    # set all arguments into instance variables
    method(__method__).parameters.map do |_, name|
      instance_variable_set(
        "@#{name}",
        binding.local_variable_get(name)
      )
    end

    self.texture = evaluate_texture(file_path: file_path, texture: texture)
  end

  def draw
    binding.pry if texture.sdl_texture.nil?
    $app.sdl_renderer.copy(
      texture.sdl_texture,
      nil,
      SDL2::Rect[x, y, width, height]
    )
  end

  private

  def evaluate_texture(file_path: nil, texture: nil)
    raise ArgumentError, 'cannot pass in both `file_path` and `texture`' if file_path && texture
    if file_path
      Texture.load(file_path)
    else
      texture
    end
  end

  def self.new_from_render(x: 0, y: 0, width:, height:)
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

    image = Image.new(
      x: x,
      y: y,
      width: width,
      height: height,
      texture: Texture.new(
        sdl_texture: sdl_texture
      )
    )

    image
  end
end
