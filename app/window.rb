class Window
  attr_accessor :width, :height, :sdl_window, :sdl_renderer

  def initialize(width:, height:, sdl_window_flags: SDL2::Window::Flags::SHOWN | SDL2::Window::Flags::OPENGL)
    @width = width
    @height = height

    @sdl_window = SDL2::Window.create(
      'Isekai',
      SDL2::Window::POS_CENTERED,
      SDL2::Window::POS_CENTERED,
      @width,
      @height,
      sdl_window_flags
    )

    set_sdl_renderer
  end

  def set_sdl_renderer
    @sdl_renderer = sdl_window.create_renderer(-1, 0)
  end
end
