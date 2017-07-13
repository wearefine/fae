describe InputLabeler do

  describe 'label' do

    it 'returns a nice label for acronym' do

      label = InputLabeler.label('ceo_quote')
      expect(label).to eq(", label: 'CEO Quote'")

    end

    it 'handles a non-conventional acronym' do

      label = InputLabeler.label('ph_level')
      expect(label).to eq(", label: 'pH Level'")

    end

    it 'places helper text for common fields' do

      label = InputLabeler.label('seo_title')
      expect(label).to eq(", label: 'SEO Title', helper_text: 'Company Name | Keyword-driven description of the page section. Approx 65 characters.'")

    end

  end

end