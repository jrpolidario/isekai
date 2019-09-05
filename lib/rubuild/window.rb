module Rubuild
  class Window
    attr_accessor :max_fps, :sdl_window, :sdl_renderer

    def initialize(
      title:,
      width:,
      height:,
      max_fps:,
      sdl_window_flags: SDL2::Window::Flags::SHOWN | SDL2::Window::Flags::OPENGL | SDL2::Window::Flags::FULLSCREEN_DESKTOP
    )
      @title = title
      current_display_mode = SDL2::Display.displays[0].current_mode
      _width = width == :full ? current_display_mode.w : width
      _height = height == :full ? current_display_mode.h : height
      @max_fps = max_fps

      @sdl_window = SDL2::Window.create(
        @title,
        SDL2::Window::POS_CENTERED,
        SDL2::Window::POS_CENTERED,
        _width,
        _height,
        sdl_window_flags
      )

      set_sdl_renderer
    end

    def set_sdl_renderer
      @sdl_renderer = sdl_window.create_renderer(-1, SDL2::Renderer::Flags::ACCELERATED)
      # @sdl_renderer.blend_mode = SDL2::BlendMode::BLEND
    end

    # delegate

    def width
      sdl_window.size[0]
    end

    def height
      sdl_window.size[1]
    end
  end

end
