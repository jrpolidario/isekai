Dir[File.join(__dir__, 'rubuild', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'rubuild', 'extensions', '*.rb')].each { |file| require file }

module Rubuild
end
