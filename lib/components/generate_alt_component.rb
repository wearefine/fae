module GenerateAltComponent
  # To avoid deprecation warning, you need to make the wrapper_options explicit
  # even when they won't be used.
  def generate_alt(wrapper_options = nil)
    @generate_alt ||= begin
      options[:generate_alt].to_s.html_safe if options[:generate_alt].present?
    end
  end
end

SimpleForm.include_component(GenerateAltComponent)