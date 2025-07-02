module Translation
  def translation
    if options[:translate].present?
      options[:translate].html_safe
    end
  end
end

SimpleForm.include_component(Translation)
