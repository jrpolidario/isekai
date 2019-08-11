class EasyStruct < OpenStruct
  # raise if "getter" is undefined but not when "setter"
  # def method_missing(method_name, *args)
  #   raise NoMethodError, "`#{method_name}` is neither a property nor a defined method" unless method_name.to_s.end_with?('=') || to_h.has_key?(method_name.to_s)
  #   super
  # end
end
