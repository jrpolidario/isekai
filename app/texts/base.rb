module Texts
  class Base < Rubuild::Text
  end
end

Dir[File.join(__dir__, '**', 'self.rb')].each { |file| require file }
