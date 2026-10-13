require 'rails_helper'
require_relative '../../tasks/fae_css_builder'

describe 'admin stylesheets' do
  it 'ships a fae_admin.css that matches app/stylesheets' do
    expect(FaeCssBuilder.current?).to be(true), 'run `bundle exec rake fae:css:build` and commit the result'
  end

  describe 'in the admin layout' do
    before do
      admin_login
      get Rails.application.routes.url_helpers.admin_wines_path
    end

    it 'links the prebuilt stylesheet followed by the host fae_custom stylesheet' do
      hrefs = response.body.scan(/<link[^>]+rel="stylesheet"[^>]+href="([^"]+)"/).flatten

      expect(hrefs.map { |h| h[%r{/assets/(fae_\w+)}, 1] }).to eq(%w[fae_admin fae_custom])
    end

    it 'serves the stylesheet with fonts and images resolved to asset paths' do
      href = response.body[%r{href="(/assets/fae_admin[^"]+\.css)"}, 1]
      get href
      css = response.body

      expect(css).to match(%r{url\(/assets/fae/lato-regular-webfont-\h+\.woff\)})
      expect(css).to match(%r{url\(/assets/fae/error_bg-\h+\.jpg\)})
      expect(css).not_to include('url("fae/')
    end
  end
end
