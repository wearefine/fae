class HelperTexter

  class << self

    # places helper_text attr for input in form view
    # for recurring fields in every project that always have the same helper text
    def helper_text(field)
      case field
      when 'seo_title'
       return ", helper_text: 'Company Name | Keyword-driven description of the page section. Approx 65 characters.'"
      when 'seo_description'
       return ", helper_text: 'Displayed in search engine results. Under 150 characters.'"
      else
       ''
      end
    end

  end

end