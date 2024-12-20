module Rubuild
  class Application
    module EnvironmentHelpers
      def env?(environment)
        ENV['RUBUILD_ENV'].to_sym == environment
      end

      def production?
        env? :production
      end

      def development?
        env? :development
      end

      def test?
        env? :test
      end
    end
  end
end
