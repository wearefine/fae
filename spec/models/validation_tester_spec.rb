describe ValidationTester do

  describe 'slug_regex' do
    it "does not allow spaces" do
      validation_test = FactoryGirl.build(:validation_tester, second_slug: 'invalid slug')
      expect(validation_test).to be_invalid
    end

    it "does not allow special characters" do
      validation_test = FactoryGirl.build(:validation_tester, second_slug: 'invalid-slug!')
      expect(validation_test).to be_invalid
    end

    it "allows properly formatted slug" do
      validation_test = FactoryGirl.build(:validation_tester, second_slug: 'valid-slug')
      expect(validation_test).to be_valid
    end
  end

  describe 'email_regex' do
    it "does not allow spaces" do
      validation_test = FactoryGirl.build(:validation_tester, email: 'with @spaces.com', second_slug: 'is-valid')
      expect(validation_test).to be_invalid
    end

    it "allows a legit email" do
      validation_test = FactoryGirl.build(:validation_tester, email: 'totally@legit.com', second_slug: 'is-valid')
      expect(validation_test).to be_valid
    end
  end

  describe 'url_regex' do
    it "does not allow url without http(s)" do
      validation_test = FactoryGirl.build(:validation_tester, url: 'poop.bike', second_slug: 'is-valid')
      expect(validation_test).to be_invalid
    end

    it "allows a legit email" do
      validation_test = FactoryGirl.build(:validation_tester, url: 'http://poop.bike/', second_slug: 'is-valid')
      expect(validation_test).to be_valid
    end
  end

  describe 'zip_regex' do
    it "does not allow less than 5" do
      validation_test = FactoryGirl.build(:validation_tester, zip: '1234', second_slug: 'is-valid')
      expect(validation_test).to be_invalid
    end

    it "allows a legit zip code" do
      validation_test = FactoryGirl.build(:validation_tester, zip: '97214', second_slug: 'is-valid')
      expect(validation_test).to be_valid
    end
  end

  describe 'youtube_regex' do
    it "does not allow special characters" do
      validation_test = FactoryGirl.build(:validation_tester, youtube_url: 'pewpew_pew!', second_slug: 'is-valid')
      expect(validation_test).to be_invalid
    end

    it "allows a legit youtube id" do
      validation_test = FactoryGirl.build(:validation_tester, youtube_url: 'ZwBRX_h3U1U', second_slug: 'is-valid')
      expect(validation_test).to be_valid
    end
  end

end