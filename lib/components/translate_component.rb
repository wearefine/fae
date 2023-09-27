module TranslateComponent
  # To avoid deprecation warning, you need to make the wrapper_options explicit
  # even when they won't be used.
  def translate(wrapper_options = nil)
    @translate ||= begin
      options[:translate].to_s.html_safe if options[:translate].present?
    end
  end
end

SimpleForm.include_component(TranslateComponent)