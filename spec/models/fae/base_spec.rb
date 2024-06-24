require 'rails_helper'

describe Fae::BaseModelConcern do

  describe '#to_csv' do
    context 'when to_csv is run' do
      it 'it should return a csv with the correct data items' do
        release1 = FactoryBot.create(:release, id: 1, release_date: Date.today)
        @items = Release.for_fae_index
        @csv = CSV.parse(@items.to_csv)
        expect(@csv.first) == Release.column_names

        Release.column_names.each do |field|
          if release1[field].present?
            expect(@csv.second).to include(release1[field].to_s)
          end
        end

      end
    end
  end

  describe '#fae_nested_parent' do
    context 'when defined in a model' do
      it 'should return a symbol' do
        aroma = FactoryBot.build_stubbed(:aroma)
        expect(aroma.fae_nested_parent).to eq(:release)
      end
    end

    context 'when not defined in a model' do
      it 'should return nil' do
        release = FactoryBot.build_stubbed(:release)
        expect(release.fae_nested_parent).to eq(nil)
      end
    end
  end

  describe '#fae_nested_foreign_key' do
    context 'when #fae_nested_parent is defined in a model' do
      it 'should return a foreign key' do
        aroma = FactoryBot.build_stubbed(:aroma)
        expect(aroma.fae_nested_foreign_key).to eq('release_id')
      end
    end

    context 'when #fae_nested_parent is not defined in a model' do
      it 'should return nil' do
        release = FactoryBot.build_stubbed(:release)
        expect(release.fae_nested_foreign_key).to eq(nil)
      end
    end
  end

  describe '#fae_translate' do
    it 'should translate specified attributes' do
      wine = FactoryBot.build_stubbed(:wine)

      expect(wine.name).to eq( wine.send("name_#{I18n.locale}") )

      # Description is not explicitly translated even though it has international attributes
      expect( wine.try(:description) ).to eq(nil)
    end

    it 'should find_by translated attribute' do
      wine = FactoryBot.create(:wine, name_en: 'Funky', name_zh: 'Funky', name_ja: 'Funky')

      expect( Wine.find_by_name('Funky') ).to be_present
    end

    it 'should translate Fae::StaticPage attributes' do
      FactoryBot.create(:contact_us_page)
      contact_page = home_page = ContactUsPage.instance
      contact_page.create_body_en(attached_as: 'body_en', content: 'EN body')
      contact_page.create_body_zh(attached_as: 'body_zh', content: 'ZH body')

      I18n.locale = :zh
      expect(contact_page.body_content).to eq('ZH body')

      I18n.locale = :en
      expect(contact_page.body_content).to eq('EN body')
    end
  end

  describe '#format_and_send_slack' do
    it 'should send a slack notification if message is present' do
      wine = FactoryBot.create(:wine)
      field_name_symbol = :on_prod

      test_message = "Dummy - [asdf](http://localhost/admin/wines/#{wine.id}/edit) (Wine) is live on prod"
      allow(wine).to receive(:slack_message).with(field_name_symbol).and_return(test_message)
      expect(Fae::SlackNotification).to receive(:new).and_return(double(send_slack: true))

      wine.format_and_send_slack(field_name_symbol)
    end

    it 'should not send a slack notification if message is not present' do
      wine = FactoryBot.create(:wine)
      field_name_symbol = :name_en

      allow(wine).to receive(:slack_message).with(field_name_symbol).and_return(nil)
      expect(Fae::SlackNotification).not_to receive(:new)

      wine.format_and_send_slack(field_name_symbol)
    end
  end

end
