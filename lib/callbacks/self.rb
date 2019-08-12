module Callbacks
  VERSION = '1.0.0'.freeze

  VALID_OPTION_KEYS = [:if].freeze

  def self.included(base)
    base.instance_variable_set(:@before_callbacks, {})
    base.instance_variable_set(:@after_callbacks, {})
    base.singleton_class.attr_accessor :before_callbacks, :after_callbacks
    base.extend ClassMethods
    base.include InstanceMethods
    base.prepend Prepended.new
  end

  class Prepended < Module
  end

  module ClassMethods

    def before(method_name, callback_method_name = nil, options = {}, &callback_proc)
      callback_method_name_or_proc = callback_proc || callback_method_name
      unless [Symbol, String, Proc].any? { |klass| callback_method_name_or_proc.is_a? klass }
        raise ArgumentError, "Only `Symbol`, `String` or `Proc` allowed for `method_name`, but is #{callback_method_name_or_proc.class}"
      end

      invalid_option_keys = options.keys - VALID_OPTION_KEYS
      unless invalid_option_keys.empty?
        raise ArgumentError, "Invalid `options` keys: #{invalid_option_keys}. Valid are only: #{VALID_OPTION_KEYS}"
      end
      if options[:if] && !([Symbol, String, Proc].any? { |klass| callback_method_name_or_proc.is_a? klass })
        raise ArgumentError, "Only `Symbol`, `String` or `Proc` allowed for `options[:if]`, but is #{options[:if].class}"
      end

      self.before_callbacks ||= {}
      self.before_callbacks[method_name.to_sym] ||= []
      self.before_callbacks[method_name.to_sym] << [callback_method_name_or_proc, options[:if]]

      callbacks_prepended_module_instance = self.ancestors.reverse.detect { |ancestor| ancestor.is_a? Callbacks::Prepended }

      # dont redefine, to save cpu cycles
      unless callbacks_prepended_module_instance.method_defined? method_name
        callbacks_prepended_module_instance.define_method method_name do |*args|
          run_before_callbacks(method_name, *args)
          super_value = super(*args)
          run_after_callbacks(method_name, *args)
        end
      end
    end

    def before!(method_name, *remaining_args)
      raise ArgumentError, "`#{method_name}` is not or not yet defined for #{self}" unless method_defined? method_name
      before(method_name, *remaining_args)
    end

    # TODO
    # def around
    # end

    def after(method_name, callback_method_name = nil, options = {}, &callback_proc)
      callback_method_name_or_proc = callback_proc || callback_method_name
      unless [Symbol, String, Proc].include? callback_method_name_or_proc.class
        raise ArgumentError, "Only `Symbol`, `String` or `Proc` allowed for `method_name`, but is #{callback_method_name_or_proc.class}"
      end

      invalid_option_keys = options.keys - VALID_OPTION_KEYS
      unless invalid_option_keys.empty?
        raise ArgumentError, "Invalid `options` keys: #{invalid_option_keys}. Valid are only: #{VALID_OPTION_KEYS}"
      end
      if options[:if] && ![Symbol, String, Proc].include?(options[:if].class)
        raise ArgumentError, "Only `Symbol`, `String` or `Proc` allowed for `options[:if]`, but is #{options[:if].class}"
      end

      self.after_callbacks ||= {}
      self.after_callbacks[method_name.to_sym] ||= []
      self.after_callbacks[method_name.to_sym] << [callback_method_name_or_proc, options[:if]]

      callbacks_prepended_module_instance = self.ancestors.reverse.detect { |ancestor| ancestor.is_a? Callbacks::Prepended }

      # dont redefine, to save cpu cycles
      unless callbacks_prepended_module_instance.method_defined? method_name
        callbacks_prepended_module_instance.define_method method_name do |*args|
          run_before_callbacks(method_name, *args)
          super_value = super(*args)
          run_after_callbacks(method_name, *args)
        end
      end
    end

    def after!(method_name, *remaining_args)
      raise ArgumentError, "`#{method_name}` is not or not yet defined for #{self}" unless method_defined? method_name
      before(method_name, *remaining_args)
    end
  end

  module InstanceMethods

    def run_before_callbacks(method_name, *args)
      before_callbacks = self.class.before_callbacks[method_name.to_sym]

      unless before_callbacks.nil?
        before_callbacks.each do |before_callback, options_if|
          is_condition_truthy = true

          if options_if
            is_condition_truthy = instance_exec *args, &options_if
          end

          if is_condition_truthy
            if before_callback.is_a? Proc
              instance_exec *args, &before_callback
            else
              send before_callback
            end
          end
        end
      end
    end

    def run_after_callbacks(method_name, *args)
      after_callbacks = self.class.after_callbacks[method_name.to_sym]

      unless after_callbacks.nil?
        after_callbacks.each do |after_callback, options_if|
          is_condition_truthy = true

          if options_if
            is_condition_truthy = instance_exec *args, &options_if
          end

          if is_condition_truthy
            if after_callback.is_a? Proc
              instance_exec *args, &after_callback
            else
              send after_callback
            end
          end
        end
      end
    end
  end
end
