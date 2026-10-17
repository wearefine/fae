require 'rails_helper'
require_relative '../../tasks/fae_js_builder'

describe 'admin javascripts' do
  it 'ships a fae_admin.js that matches app/legacy_js' do
    expect(FaeJsBuilder.current?).to be(true), 'run `bundle exec rake fae:js:build` and commit the result'
  end

  it 'bundles the libraries and modules the admin needs' do
    js = FaeJsBuilder::OUTPUT.read

    expect(js).to include('jQuery JavaScript Library')
    expect(js).to include('jquery-ujs')
    expect(js).to include('Fae.init = function')
    expect(js).to include('Fae.form.slugger')
    expect(js).to include('jQuery.trumbowyg')
    expect(js).not_to match(%r{^//= require}), 'Sprockets directives should be resolved in the build'
  end

  describe 'in the admin layout' do
    before do
      admin_login
      get Rails.application.routes.url_helpers.admin_wines_path
    end

    it 'loads the prebuilt script before the importmap modules' do
      srcs = response.body.scan(/<script[^>]+src="([^"]+)"/).flatten.map { |src| src[%r{/assets/([\w/.-]+?)(?:-\h{8,})?\.js}, 1] }

      expect(srcs.first).to eq('fae_admin')
      expect(response.body.index('fae_admin')).to be < response.body.index('type="importmap"')
    end

    it 'serves the script as a single file' do
      href = response.body[%r{src="(/assets/fae_admin[^"]+\.js)"}, 1]
      get href

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Fae.init = function')
    end

    it 'does not link the individual legacy files' do
      expect(response.body).not_to match(%r{/assets/fae/(application|admin|fae_init)})
    end
  end
end
