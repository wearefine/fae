require 'spec_helper'

feature 'Turbo', js: true do
  before(:each) do
    admin_login
    visit fae.root_path
    eventually { expect(page.evaluate_script('typeof window.Turbo')).to eq('object') }
  end

  around do |example|
    original = Fae.turbo_drive
    example.run
    Fae.turbo_drive = original
  end

  # Marks the current document, adds a plain link, follows it and reports whether the document survived.
  # A full page load replaces the document and loses the marker; a Turbo visit keeps it.
  def follows_link_without_reload?
    page.execute_script(<<~JS)
      window.faeDocumentMarker = true
      var link = document.createElement('a')
      link.id = 'plain-link'
      link.href = '#{admin_wines_path}'
      link.textContent = 'Wines'
      document.querySelector('#js-main-content').appendChild(link)
    JS

    find('#plain-link').click
    expect(page).to have_current_path(admin_wines_path)

    page.evaluate_script('window.faeDocumentMarker === true')
  end

  scenario 'is loaded with Drive off by default' do
    Fae.turbo_drive = false
    visit fae.root_path
    eventually { expect(page.evaluate_script('typeof window.Turbo')).to eq('object') }

    expect(page.evaluate_script('Turbo.session.drive')).to be false
    expect(follows_link_without_reload?).to be false
  end

  scenario 'drives plain links without a full page load when Drive is enabled' do
    Fae.turbo_drive = true
    visit fae.root_path
    eventually { expect(page.evaluate_script('Turbo.session.drive')).to be true }

    expect(follows_link_without_reload?).to be true
  end

  scenario 'opts a region in with data-turbo="true" while Drive is off' do
    Fae.turbo_drive = false
    visit fae.root_path
    eventually { expect(page.evaluate_script('typeof window.Turbo')).to eq('object') }
    page.execute_script("document.querySelector('#js-main-content').setAttribute('data-turbo', 'true')")

    expect(follows_link_without_reload?).to be true
  end
end
