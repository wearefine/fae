require 'rails_helper'

describe 'Turbo in the admin layout' do
  before do
    admin_login
    get Rails.application.routes.url_helpers.admin_wines_path
  end

  around do |example|
    original = Fae.turbo_drive
    example.run
    Fae.turbo_drive = original
  end

  it 'pins Turbo in Fae\'s importmap' do
    imports = JSON.parse(response.body[%r{<script type="importmap"[^>]*>(.*?)</script>}m, 1])['imports']

    expect(imports).to include('@hotwired/turbo-rails')
  end

  def meta_content(name)
    response.body[/<meta[^>]*name="#{name}"[^>]*>/][/content="([^"]*)"/, 1]
  end

  it 'tells the browser whether Drive is on' do
    Fae.turbo_drive = false
    get Rails.application.routes.url_helpers.admin_wines_path
    expect(meta_content('fae-turbo-drive')).to eq('false')

    Fae.turbo_drive = true
    get Rails.application.routes.url_helpers.admin_wines_path

    expect(meta_content('fae-turbo-drive')).to eq('true')
  end

  it 'keeps admin pages out of Turbo\'s snapshot cache' do
    expect(meta_content('turbo-cache-control')).to eq('no-cache')
  end

  it 'reloads the page when Fae\'s assets change' do
    tracked = response.body.scan(/<(?:script|link)[^>]*data-turbo-track="reload"[^>]*>/)

    expect(tracked.join).to include('fae_admin').and include('fae_custom')
  end
end
