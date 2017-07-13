class InputLabeler

  Acronyms = [
    'lol',
    'pdf',
    'seo',
    'ceo',
    'sku',
    'url',
    'ava',
    'cta',
    'ph'
  ]

  SpecialCases = [
    'ph'
  ]

  class << self

    # places label attr + helper text for input in form view
    def label(field)
      label = ''
      Acronyms.each do |acronym|
        label = ", label: '#{titleize_string(field)}'" if acronym_is_legit?(field, acronym)
      end
      label + helper_text(field)
    end

    # split underscored_string and capitalize acronym parts: seo_description -> SEO Description
    def titleize_string(underscored_string)
      return '' if underscored_string.blank?

      parts = underscored_string.split('_')
      parts.collect do |part|
        if SpecialCases.include?(part)
          special_case(part)
        elsif Acronyms.include?(part)
          part.upcase
        else
          part.titleize
        end
      end.join(' ')
    end

    private

    # special cases where capitalization is unconventional
    def special_case(part)
      case part
      when 'ph'
        return 'pH'
      end
    end

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

    # detect position of acronym in field to avoid false positives like 'ph' hitting for 'phone_number'
    def acronym_is_legit?(field, acronym)
      return false if field[acronym].blank?

      acronym_length = acronym.length
      acronym_index  = field.index(acronym)
      markers        = [nil,'_']

      if acronym_index == 0 && markers.include?(field[acronym_index + acronym_length])
        return true
      end
      if markers.include?(field[acronym_index - 1]) && markers.include?(field[acronym_index + acronym_length])
        return true
      end
    end

  end

end