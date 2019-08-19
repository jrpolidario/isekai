module Images
  class Base < Rubuild::Image
  end
end

Dir[File.join(__dir__, '**', 'self.rb')].each { |file| require file }
