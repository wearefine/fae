module GenerateAlt
  def generate_alt(wrapper_options = nil)
    if options[:generate_alt].present?
      options[:generate_alt].html_safe
    end
  end
end

SimpleForm.include_component(GenerateAlt)