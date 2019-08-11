Dir[File.join(__dir__, 'application', '*.rb')].each { |file| require file }

class Application
  attr_accessor :state, :inputs, :outputs, :window, :sdl_renderer, :temp, :internal

  FPS_RESET_INTERVAL = 4

  include EnvironmentHelpers

  class << self
    def config
      {
        window: {
          width: 1280,
          height: 720
        }
      }
    end

    def init!
      raise 'already initialised!' if $app

      SDL2.init(SDL2::INIT_EVERYTHING)
      SDL2::TTF.init

      $app = Application.new

      $app.state = EasyStruct.new
      $app.inputs = EasyStruct.new do
        def key_down?(key)
          $app.has_key? current_inputs
        end
      end
      $app.outputs = EasyStruct.new
      $app.internal = EasyStruct.new
      $app.temp = EasyStruct.new

      $app.window = Window.new(config.fetch(:window))
      $app.window.sdl_renderer

      # delegate
      $app.sdl_renderer = $app.window.sdl_renderer
      $app
    end
  end

  def tick
    internal.frames = 0
    internal.start_time = Time.now

    loop do
      loop_inits
      handle_events

      yield

      render_all
      loop_cleanups
    end
  end

  private

  def loop_inits
    set_fps
    internal.frames += 1
    internal.current_inputs = Set.new
  end

  def set_fps
    if internal.fps.nil? || Time.now.to_i % FPS_RESET_INTERVAL == 0
      if !internal.is_fps_reset_interval
        internal.fps_reset_interval_frames = internal.frames
        internal.fps_reset_interval_start_time = Time.now
      end

      internal.is_fps_reset_interval = true
    else
      internal.is_fps_reset_interval = false
    end

    internal.fps = (
      (internal.frames - internal.fps_reset_interval_frames) /
      (Time.now - internal.fps_reset_interval_start_time).to_f
    ).to_i
  end

  def loop_cleanups
  end

  def render_all
    sdl_renderer.present
    sdl_renderer.clear
  end

  def handle_events
    while event = SDL2::Event.poll
      case event
      when SDL2::Event::KeyDown
        internal.current_inputs << event.sym
      when SDL2::Event::Quit
        exit
      end
    end
  end
end
