# frozen_string_literal: true

require "pathname"

ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../Gemfile",
  Pathname.new(__FILE__).realpath)

require "rubygems"
require "bundler/setup"

Bundler.require(:default)
Bundler.require(ENV.fetch('RUBUILD_ENV'))

RUBUILD_PATH = File.expand_path('..', __dir__)

Dir[File.join(RUBUILD_PATH, 'lib', '*.rb')].each { |file| require file }
load(File.join(RUBUILD_PATH, 'app', 'main.rb'))
