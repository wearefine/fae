describe InputLabeler do

  describe 'label' do

    it 'returns a nice label for acronym' do

      label = InputLabeler.label('ceo_quote')
      expect(label).to eq(", label: 'CEO Quote'")

      label = InputLabeler.label('our_ceo')
      expect(label).to eq(", label: 'Our CEO'")

    end

    it 'handles a non-conventional acronym' do

      label = InputLabeler.label('ph_level')
      expect(label).to eq(", label: 'pH Level'")

    end

    it 'places helper text for common fields' do

      label = InputLabeler.label('seo_title')
      expect(label).to eq(", label: 'SEO Title', helper_text: 'Company Name | Keyword-driven description of the page section. Approx 65 characters.'")

      label = InputLabeler.label('seo_description')
      expect(label).to eq(", label: 'Displayed in search engine results. Under 150 characters.'")

    end

    it 'does not get false positives' do

      label = InputLabeler.label('phone_number')
      expect(label).to eq("")

      label = InputLabeler.label('curl_handle')
      expect(label).to eq("")

    end

  end

end