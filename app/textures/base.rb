module Textures
  class Base < Rubuild::Texture
  end
end

Dir[File.join(__dir__, '**', 'self.rb')].each { |file| require file }
