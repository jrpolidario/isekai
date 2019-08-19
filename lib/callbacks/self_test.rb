# require_relative 'self.rb'
# require 'test/unit.rb'
# require 'byebug'
#
# class TestCallbacks < Test::Unit::TestCase
#
#   def test_before_bang_should_raise_error_if_method_not_defined
#     assert_raise ArgumentError do
#       Class.new do
#         include Callbacks
#
#         before! :bar, :say_hi_first
#
#         def bar
#         end
#
#         def say_hi_first
#           puts 'Hi'
#         end
#       end
#     end
#
#     assert_nothing_raised do
#       Class.new do
#         include Callbacks
#
#         def bar
#         end
#
#         before! :bar, :say_hi_first
#
#         def say_hi_first
#           puts 'Hi'
#         end
#       end
#     end
#   end
#
#   def test_after_bang_should_raise_error_if_method_not_defined
#     assert_raise ArgumentError do
#       Class.new do
#         include Callbacks
#
#         after! :bar, :say_hi_first
#
#         def bar
#         end
#
#         def say_hi_first
#           puts 'Hi'
#         end
#       end
#     end
#
#     assert_nothing_raised do
#       Class.new do
#         include Callbacks
#
#         def bar
#         end
#
#         after! :bar, :say_hi_first
#
#         def say_hi_first
#           puts 'Hi'
#         end
#       end
#     end
#   end
#
#   def test_before_should_not_raise_error_if_method_not_defined
#     assert_nothing_raised do
#       Class.new do
#         include Callbacks
#
#         before :bar, :say_hi_first
#
#         def say_hi_first
#           puts 'Hi'
#         end
#       end
#     end
#   end
#
#   def test_after_should_not_raise_error_if_method_not_defined
#     assert_nothing_raised do
#       Class.new do
#         include Callbacks
#
#         after :bar, :say_hi_first
#
#         def say_hi_first
#           puts 'Hi'
#         end
#       end
#     end
#   end
#
#   def test_run_callbacks_should_run_defined_callbacks_for_that_method
#     klass = Class.new do
#       include Callbacks
#
#       attr_accessor :test_string_sequence
#
#       def initialize
#         @test_string_sequence = []
#       end
#
#       # below is intentionally defined not in order, for sequence testing
#
#       before :bar, :say_hi_first
#
#       after :bar, :say_goodbye
#
#       before :bar do
#         @test_string_sequence << 'Hello'
#       end
#
#       after :bar do
#         @test_string_sequence << 'Paalam'
#       end
#
#       def say_hi_first
#         @test_string_sequence << 'Hi'
#       end
#
#       def say_goodbye
#         @test_string_sequence << 'Goodbye'
#       end
#
#       def bar
#         @test_string_sequence << 'bar is called'
#         @bar
#       end
#     end
#
#     instance = klass.new
#     instance.bar
#
#     assert_equal instance.test_string_sequence, ['Hi', 'Hello', 'bar is called', 'Goodbye', 'Paalam']
#   end
#
#   def test_conditional_callbacks
#     klass = Class.new do
#       include Callbacks
#
#       attr_accessor :test_string_sequence, :baz
#       attr_writer :bar
#
#       def initialize
#         @test_string_sequence = []
#       end
#
#       before :bar=, :do_a, if: lambda { |arg| arg == 'hooman' && @baz = true }
#       before :bar=, :do_b, if: lambda { |arg| arg == 'hooman' && @baz = false }
#       before :bar=, :do_c, if: lambda { |arg| arg == 'dooge' && @baz = true }
#       before :bar=, if: lambda { |arg| arg == 'dooge' && @baz = true } do
#         do_d
#       end
#
#       def do_a
#         @test_string_sequence << 'a'
#       end
#
#       def do_b
#         @test_string_sequence << 'b'
#       end
#
#       def do_c
#         @test_string_sequence << 'c'
#       end
#
#       def do_d
#         @test_string_sequence << 'd'
#       end
#     end
#
#     instance = klass.new
#     instance.baz = true
#     instance.bar = 'dooge'
#     assert_equal instance.test_string_sequence, ['c', 'd']
#   end
#
#   def test_instance_of_subclass_of_proc_or_string_or_symbol_should_not_raise_argument_error
#     string_subclass = Class.new(String)
#
#     klass = Class.new do
#       include Callbacks
#
#       attr_accessor :test_string_sequence
#       attr_reader :bar
#
#       def initialize
#         @test_string_sequence = []
#       end
#
#       before :bar, string_subclass.new('say_hi_first')
#
#       def say_hi_first
#         @test_string_sequence << 'Hi'
#       end
#     end
#
#     instance = klass.new
#     instance.bar
#
#     assert_equal instance.test_string_sequence, ['Hi']
#   end
#
#   def test_ancestral_callbacks_triggered_by_subclass_instance_methods
#     base_class = Class.new do
#       include Callbacks
#
#       attr_accessor :test_string_sequence
#       attr_reader :bar
#
#       def initialize
#         @test_string_sequence = []
#       end
#
#       before :bar, :say_hi_first
#
#       def say_hi_first
#         @test_string_sequence << 'Hi'
#       end
#     end
#
#     sub_class = Class.new(base_class) do
#     end
#
#     instance = sub_class.new
#     instance.bar
#
#     assert_equal instance.test_string_sequence, ['Hi']
#   end
#
#   def test_singleton_callbacks
#     klass = Class.new do
#       include Callbacks
#
#       attr_accessor :test_string_sequence
#       attr_accessor :bar
#
#       def initialize
#         @test_string_sequence = []
#       end
#     end
#
#     instance_1 = klass.new
#     instance_1.before :bar= do |arg|
#       @test_string_sequence << "Hi #{arg}"
#     end
#
#     instance_2 = klass.new
#
#     instance_1.bar = 2
#     instance_2.bar = 3
#
#     assert_equal instance_1.test_string_sequence, ['Hi 2']
#     assert_equal instance_2.test_string_sequence, []
#   end
#
#   def test_singleton_callbacks_and_ancestral_callbacks_triggered_by_subclass_instance_methods
#     base_class = Class.new do
#       include Callbacks
#
#       attr_accessor :test_string_sequence
#       attr_writer :bar
#
#       def initialize
#         @test_string_sequence = []
#       end
#
#       before :bar= do |arg|
#         @test_string_sequence << "Hello #{arg}"
#       end
#
#       after :bar= do |arg|
#         @test_string_sequence << "Konnichi wa #{arg}"
#       end
#     end
#
#     sub_class = Class.new(base_class) do
#     end
#
#     instance_1 = sub_class.new
#     instance_1.before :bar= do |arg|
#       @test_string_sequence << "Hi #{arg}"
#     end
#
#     instance_1.after :bar= do |arg|
#       @test_string_sequence << "Kumusta #{arg}"
#     end
#
#     # instance_2 = sub_class.new
#
#     instance_1.bar = 2
#     # instance_2.bar = 3
#
#     assert_equal instance_1.test_string_sequence, ['Hello 2', 'Hi 2', 'Konnichi wa 2', 'Kumusta 2']
#     # assert_equal instance_2.test_string_sequence, ['Hello 3']
#   end
# end
