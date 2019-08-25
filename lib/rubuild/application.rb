Dir[File.join(__dir__, 'application', '*.rb')].each { |file| require file }

module Rubuild
  class Application
    attr_accessor :name, :state, :inputs, :outputs, :window, :sdl_renderer, :temp, :internal
    delegate :sdl_renderer, to: :window

    FPS_RESET_INTERVAL = 0.2 # seconds

    include EnvironmentHelpers

    class << self
      def config
        {
          window: {
            width: :full,
            height: :full,
            max_fps: 60
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

        handle_debugger
        handle_autoreload_file_changges

        $app
      end

      private

      def handle_debugger
        if $app.development?
          Thread.new do
            binding.pry
          end
          sleep(0.1)
        end
      end

      def handle_autoreload_file_changges
        listener = Listen.to(
          *Dir.glob(File.join(RUBUILD_PATH, 'app', '**', '*/')),
          *Dir.glob(File.join(RUBUILD_PATH, 'app')),
          *Dir.glob(File.join(RUBUILD_PATH, 'lib', '**', '*/')),
          *Dir.glob(File.join(RUBUILD_PATH, 'lib')),
          only: /\.rb$/
        ) do |modified, added, removed|
          modified.each do |modified|
            load modified
            puts "autorealoaded modified file: #{modified}"
          end

          added.each do |added|
            load added
            puts "autoloaded new file: #{added}"
          end
        end
        listener.start # not blocking
      end
    end

    def tick
      internal.frame_start_time = Time.now.to_f
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
      fps_start_handler
      internal.current_inputs = Set.new
    end

    def loop_cleanups
      fps_end_handler
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

    def fps_start_handler
      internal.frame_start_time = Time.now

      if internal.fps.nil? || internal.frame_start_time.to_f >= internal.fps_reset_interval_start_time.to_f + FPS_RESET_INTERVAL
        internal.fps_reset_interval_frames = internal.frames
        internal.fps_reset_interval_start_time = internal.frame_start_time
      end

      # internal.frames += 1
      #
      # internal.fps = (
      #   (internal.frames - internal.fps_reset_interval_frames) /
      #   (Time.now - internal.fps_reset_interval_start_time)
      # ).to_i
    end

    def fps_end_handler
      # # TODO: limit fps: not working properly, it seems
      # @milliseconds_per_frame ||= 1000 * 1 * 0.75 / $app.window.max_fps.to_f
      # elapsed_since_frame_start_time = Time.now - internal.frame_start_time
      # sleep((@milliseconds_per_frame - elapsed_since_frame_start_time) / 1000)

      internal.frames += 1

      internal.fps = (
        (internal.frames - internal.fps_reset_interval_frames) /
        (Time.now - internal.fps_reset_interval_start_time)
      ).to_i
    end
  end
end
