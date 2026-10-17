require 'rails_helper'

describe 'Fae asset pipeline' do
  it 'serves assets with Propshaft' do
    expect(Rails.application.assets).to be_a(Propshaft::Assembly)
  end

  describe '.check_asset_pipeline!' do
    it 'passes without sprockets-rails' do
      expect { Fae.check_asset_pipeline! }.not_to raise_error
    end

    it 'raises a helpful error when sprockets-rails is loaded' do
      stub_const('Sprockets::Railtie', Class.new)

      expect { Fae.check_asset_pipeline! }.to raise_error(/Replace `gem "sprockets-rails"` with `gem "propshaft"`/)
    end
  end

  describe '.custom_stylesheet?' do
    it 'finds the host fae_custom.css in the load path' do
      expect(Fae.custom_stylesheet?).to be(true)
    end

    it 'is false when there is none' do
      allow(Rails.application.assets.load_path).to receive(:find).with('fae_custom.css').and_return(nil)

      expect(Fae.custom_stylesheet?).to be(false)
    end
  end

  it 'does not leave Sprockets manifests behind' do
    expect(Fae::Engine.root.join('app/assets/config')).not_to exist
  end
end
