describe ValidationTester do

  describe 'slug_regex' do
    it "does not allow spaces" do
      validation_test = FactoryBot.build_stubbed(:validation_tester, second_slug: 'invalid slug')
      expect(validation_test).to be_invalid
    end

    it "does not allow special characters" do
      validation_test = FactoryBot.build_stubbed(:validation_tester, second_slug: 'invalid-slug!')
      expect(validation_test).to be_invalid
    end

    it "allows properly formatted slug" do
      validation_test = FactoryBot.build_stubbed(:validation_tester, second_slug: 'valid-slug')
      expect(validation_test).to be_valid
    end
  end

  describe 'email_regex' do
    it "does not allow spaces" do
      validation_test = FactoryBot.build_stubbed(:validation_tester, email: 'with @spaces.com')
      expect(validation_test).to be_invalid
    end

    it "allows a legit email" do
      validation_test = FactoryBot.build_stubbed(:validation_tester, email: 'totally@legit.com')
      expect(validation_test).to be_valid
    end
  end

  describe 'url_regex' do
    it "does not allow url without http(s)" do
      validation_test = FactoryBot.build_stubbed(:validation_tester, url: 'poop.bike')
      expect(validation_test).to be_invalid
    end

    it "allows a legit email" do
      validation_test = FactoryBot.build_stubbed(:validation_tester, url: 'http://poop.bike/')
      expect(validation_test).to be_valid
    end
  end

  describe 'zip_regex' do
    it "does not allow less than 5" do
      validation_test = FactoryBot.build_stubbed(:validation_tester, zip: '1234')
      expect(validation_test).to be_invalid
    end

    it "allows a legit zip code" do
      validation_test = FactoryBot.build_stubbed(:validation_tester, zip: '97214')
      expect(validation_test).to be_valid
    end
  end

  describe 'youtube_regex' do
    it "does not allow special characters" do
      validation_test = FactoryBot.build_stubbed(:validation_tester, youtube_url: 'pewpew_pew!')
      expect(validation_test).to be_invalid
    end

    it "allows a legit youtube id" do
      validation_test = FactoryBot.build_stubbed(:validation_tester, youtube_url: 'ZwBRX_h3U1U')
      expect(validation_test).to be_valid
    end
  end

end