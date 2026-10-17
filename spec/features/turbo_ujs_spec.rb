require 'spec_helper'

# jquery_ujs still handles Fae's remote forms and data-method/data-confirm links. With Turbo Drive on, a click or
# submit must be handled by exactly one of them: one request to the server, not a Turbo visit plus a UJS request.
feature 'jquery_ujs next to Turbo Drive', js: true do
  around do |example|
    original = Fae.turbo_drive
    Fae.turbo_drive = true
    example.run
    Fae.turbo_drive = original
  end

  before { admin_login }

  # [verb, path] of every request the app handled while the block ran
  def requests_during
    requests = []
    subscriber = ActiveSupport::Notifications.subscribe('process_action.action_controller') do |*, payload|
      requests << [payload[:method], payload[:path]]
    end

    yield
    requests
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber)
  end

  scenario 'a data-method delete link sends one DELETE and no extra GET' do
    release = FactoryBot.create(:release, name: 'Doomed')
    visit admin_releases_path
    eventually { expect(page).to have_css('a[data-method="delete"]') }
    path = admin_release_path(release)

    requests = requests_during do
      accept_confirm { find("a[data-method='delete'][href='#{path}']").click }
      eventually { expect(Release.exists?(release.id)).to be false }
      expect(page).to have_current_path(admin_releases_path)
    end

    expect(requests.select { |_verb, req_path| req_path.start_with?(path) }).to eq([['DELETE', path]])
  end

  scenario 'a declined confirm sends nothing' do
    release = FactoryBot.create(:release, name: 'Safe')
    visit admin_releases_path
    path = admin_release_path(release)

    requests = requests_during do
      dismiss_confirm { find("a[data-method='delete'][href='#{path}']").click }
      sleep 0.5
    end

    expect(requests).to be_empty
    expect(Release.exists?(release.id)).to be true
  end

  scenario 'a clone link sends one POST' do
    release = FactoryBot.create(:release, name: 'Ima Release')
    visit edit_admin_release_path(release)
    eventually { expect(page).to have_css('#js-header-clone') }

    requests = requests_during do
      click_link 'Clone'
      eventually { expect(Release.find_by(name: 'Ima Release-2')).to_not be_nil }
      expect(page).to have_current_path(/releases\/\d+\/edit/)
    end

    expect(requests.count { |verb, path| verb == 'POST' && path.start_with?(admin_releases_path) }).to eq(1)
  end

  scenario 'a remote nested form saves over ajax without a Turbo visit' do
    release = FactoryBot.create(:release, name: 'Ima Release')
    visit edit_admin_release_path(release)
    eventually { expect(page).to have_css('.chosen-container') }
    page.execute_script('window.faeDocumentMarker = true')

    click_link 'Add Aroma'
    within('.js-addedit-form-wrapper') do
      fill_in 'aroma_name', with: 'Cherry'
      click_button 'Save'
    end

    expect(page).to have_css('.js-addedit-form td', text: 'Cherry')
    expect(page.evaluate_script('window.faeDocumentMarker')).to be true
    expect(Aroma.where(name: 'Cherry').count).to eq(1)
  end
end
