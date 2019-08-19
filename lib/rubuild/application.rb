Dir[File.join(__dir__, 'application', '*.rb')].each { |file| require file }

module Rubuild
  class Application
    attr_accessor :name, :state, :inputs, :outputs, :window, :sdl_renderer, :temp, :internal
    delegate :sdl_renderer, to: :window

    FPS_RESET_INTERVAL = 1

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

      def init!(name:)
        raise 'already initialised!' if $app

        SDL2.init(SDL2::INIT_EVERYTHING)
        SDL2::TTF.init

        $app = Application.new
        $app.name = name

        $app.state = EasyStruct.new
        $app.inputs = EasyStruct.new do
          def key_down?(key)
            $app.has_key? current_inputs
          end
        end
        $app.outputs = EasyStruct.new
        $app.internal = EasyStruct.new
        $app.temp = EasyStruct.new

        $app.window = Window.new(
          title: name,
          **config.fetch(:window)
        )

        # delegate
        $app.sdl_renderer = $app.window.sdl_renderer

        if $app.development?
          Thread.new do
            binding.pry
          end
        end

        $app
      end
    end

    def tick
      internal.start_time = Time.now
      internal.frames = 0
      internal.fps_reset_interval_frames = internal.frames
      internal.fps_reset_interval_start_time = internal.start_time

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
      internal.current_inputs = Set.new
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

    def set_fps
      internal.frames += 1

      if internal.fps.nil? || Time.now.to_f >= internal.fps_reset_interval_start_time.to_f + FPS_RESET_INTERVAL
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
  end
end
