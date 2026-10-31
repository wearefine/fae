require 'rails_helper'

describe Fae::FormManager do

  def set_max_length(model_name, field_id, max_length, model_id: nil)
    Fae::FormManager.create!(
      form_manager_model_name: model_name,
      form_manager_model_id: model_id,
      fields: { field_id => { formManagerId: field_id, label: 'Label', helper: '', maxLength: max_length } }.to_json
    )
  end

  describe '#max_length_for' do
    it 'returns positive integers only' do
      expect(Fae::FormManager.new(fields: { 'Release_intro' => { maxLength: '150' } }.to_json).max_length_for('Release_intro')).to eq(150)
      expect(Fae::FormManager.new(fields: { 'Release_intro' => { maxLength: '' } }.to_json).max_length_for('Release_intro')).to be_nil
      expect(Fae::FormManager.new(fields: { 'Release_intro' => { maxLength: '-5' } }.to_json).max_length_for('Release_intro')).to be_nil
      expect(Fae::FormManager.new(fields: { 'Release_intro' => { maxLength: 'abc' } }.to_json).max_length_for('Release_intro')).to be_nil
      expect(Fae::FormManager.new(fields: 'not json').max_length_for('Release_intro')).to be_nil
    end
  end

  describe 'length validation overrides' do
    let(:release) { FactoryBot.build(:release) }

    it 'uses the model maximum by default' do
      release.intro = 'a' * 101
      expect(release).to_not be_valid
      expect(release.errors[:intro].first).to include('100')
    end

    it 'allows the form manager to raise the model maximum' do
      set_max_length('Release', 'Release_intro', '200')

      release.intro = 'a' * 200
      expect(release).to be_valid

      release.intro = 'a' * 201
      expect(release).to_not be_valid
      expect(release.errors[:intro].first).to include('200')
    end

    it 'allows the form manager to lower the model maximum' do
      set_max_length('Release', 'Release_intro', '50')

      release.intro = 'a' * 51
      expect(release).to_not be_valid
      expect(release.errors[:intro].first).to include('50')
    end

    it 'keeps other length options like minimum' do
      set_max_length('Release', 'Release_name', '20')

      release.name = 'ab'
      expect(release).to_not be_valid

      release.name = 'a' * 20
      expect(release).to be_valid
    end

    it 'caps the override at the column limit reported by the database' do
      set_max_length('Release', 'Release_name', '100000')
      limit = Release.columns_hash['name'].limit

      if limit.present?
        expect(Fae::FormManager.max_length_override(release, :name)).to eq(limit)
      else
        expect(Fae::FormManager.max_length_override(release, :name)).to eq(100000)
      end
    end

    it 'is ignored when the form manager is disabled' do
      set_max_length('Release', 'Release_intro', '200')
      Fae.use_form_manager = false

      release.intro = 'a' * 150
      expect(release).to_not be_valid
    ensure
      Fae.use_form_manager = true
    end

    it 'applies to Fae page content blocks' do
      page = HomePage.instance
      set_max_length('Fae::StaticPage', 'HomePage_introduction', '150', model_id: page.id)

      text_area = Fae::TextArea.new(contentable: page, attached_as: 'introduction', content: 'a' * 150)
      expect(text_area).to be_valid

      text_area.content = 'a' * 151
      expect(text_area).to_not be_valid
    end

    it 'passes the override and default to Judge for client side validation' do
      set_max_length('Release', 'Release_intro', '200')
      amv = Release.validators_on(:intro).find { |v| v.kind == :length }

      judge_hash = Judge::Validator.new(release, :intro, amv).to_hash
      expect(judge_hash[:options][:maximum]).to eq(200)
      expect(judge_hash[:options][:fae_default_maximum]).to eq(100)
      expect(judge_hash[:messages][:too_long]).to include('200')
    end
  end

end
