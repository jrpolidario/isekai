module Rubuild
  class Texture
    attr_accessor :sdl_texture
    singleton_class.attr_reader :cache

    @cache = {}

    def initialize(sdl_texture: nil, file_path: nil)
      @sdl_texture = evaluate_sdl_texture(file_path: file_path, sdl_texture: sdl_texture)
    end

    def load(filename)
      Rubuild::Texture.cache[filename] ||= (
        # bitmap = SDL2::Surface.load(filename)
        # bitmap.color_key = bitmap.pixel(0, 0)
        # texture = $app.sdl_renderer.create_texture_from(bitmap)
        # bitmap.destroy
        # texture
        $app.sdl_renderer.load_texture(filename)
      )

      self.sdl_texture = Rubuild::Texture.cache[filename]
    end

    def self.new_from_render(width:, height:)
      current_render_target = $app.sdl_renderer.create_texture(
        SDL2::PixelFormat::RGBA8888,
        SDL2::Texture::ACCESS_TARGET,
        width,
        height
      )

      # allow alpha blending (transparency)??
      current_render_target.blend_mode = SDL2::BlendMode::BLEND

      Thread.current[:rubuild_render_targets] ||= []
      Thread.current[:rubuild_render_targets] << current_render_target

      $app.sdl_renderer.render_target = current_render_target
      $app.sdl_renderer.draw_color = [0xA0, 0xA0, 0xA0, 1]
      $app.sdl_renderer.clear

    	yield

      Thread.current[:rubuild_render_targets].pop

      if Thread.current[:rubuild_render_targets].empty?
        Thread.current[:rubuild_render_targets] = nil
        $app.sdl_renderer.reset_render_target
      else
        $app.sdl_renderer.render_target = Thread.current[:rubuild_render_targets].last
      end

      Texture.new(sdl_texture: current_render_target)
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

    def draw(x:, y:, width: self.width, height: self.height, rotation: 0)
      $app.sdl_renderer.copy_ex(
        sdl_texture,
        nil, # source rect
        SDL2::Rect[x, y, width, height], # destination rect
        rotation,
        nil, # rotation anchor point: default is center of 3rd arg
        SDL2::Renderer::FLIP_NONE
      )
    end

    private

    def evaluate_sdl_texture(file_path: nil, sdl_texture: nil)
      raise ArgumentError, 'cannot pass in both `file_path` and `sdl_texture`' if file_path && sdl_texture

      if file_path
        load(
          resolved_texture_full_file_path(file_path)
        )
      else
        sdl_texture
      end
    end

    def resolved_texture_full_file_path(file_path)
      return file_path if File.exist?(file_path)

      full_app_directory_shared_path = File.join(RUBUILD_PATH, 'app', 'textures', 'shared', file_path)
      return full_app_directory_shared_path if File.exist? full_app_directory_shared_path

      app_directory_path = self.class.name.split('::').map(&:underscore)
      full_app_directory_path = File.join(RUBUILD_PATH, 'app', *app_directory_path, file_path)
      return full_app_directory_path if File.exist? full_app_directory_path

      raise ArgumentError, "file does not exist: #{full_app_directory_path}"
    end
  end
end
