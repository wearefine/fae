describe HelperTexter do

  it 'places helper text for common fields' do

    label = HelperTexter.helper_text('seo_title')
    expect(label).to eq(", helper_text: 'Company Name | Keyword-driven description of the page section. Approx 65 characters.'")

    label = HelperTexter.helper_text('seo_description')
    expect(label).to eq(", helper_text: 'Displayed in search engine results. Under 150 characters.'")

  end

end