Object.class_eval do
  def instance_variables_set(**args)
    args.each do |instance_variable_name, instance_variable_value|
      instance_variable_set instance_variable_name, instance_variable_value
    end
  end
end
