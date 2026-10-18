require 'spec_helper'

# The legacy jQuery JavaScript outlives Turbo visits (only the <body> is replaced), so every visit has to
# initialize the new body and nothing may pile up on window, document or in jQuery's data store.
feature 'Turbo visits and the legacy JavaScript', js: true do
  FOOTPRINT = <<~JS.freeze
    (function() {
      var handlers = 0;
      $(document).add(window).each(function() {
        var events = $._data(this, 'events') || {};
        Object.keys(events).forEach(function(type) { handlers += events[type].length; });
      });

      return {
        handlers: handlers,
        fch: [FCH.scroll.length, FCH.resize.length, FCH.load.length, FCH.ready.length].join(','),
        jqueryData: Object.keys($.cache).length
      };
    })()
  JS

  let(:release) { FactoryBot.create(:release, name: 'Test Release') }

  around do |example|
    original = Fae.turbo_drive
    Fae.turbo_drive = true
    example.run
    Fae.turbo_drive = original
  end

  before { admin_login }

  # A full page load discards the document, and with it these listeners and markers, so call this after each `visit`
  def track_turbo
    eventually { expect(page.evaluate_script('typeof window.Turbo')).to eq('object') }

    page.execute_script(<<~JS)
      window.faeDocumentMarker = true
      window.faeTurboLoads = 0
      window.faeLoadRoots = []
      document.addEventListener('turbo:load', function() { window.faeTurboLoads++ })
      document.addEventListener('fae:load', function(e) { window.faeLoadRoots.push(e.detail.root === document ? 'document' : 'element') })
    JS
  end

  def turbo_visit(path)
    loads = page.evaluate_script('window.faeTurboLoads')
    page.execute_script("Turbo.visit('#{path}')")

    eventually { expect(page.evaluate_script('window.faeTurboLoads')).to eq(loads + 1) }
    wait_for_animations
  end

  scenario 'initializes the new page after a visit' do
    visit fae.root_path
    track_turbo
    turbo_visit edit_admin_release_path(release)

    expect(page.evaluate_script('window.faeDocumentMarker')).to be true
    expect(page).to have_css('.chosen-container')
    expect(page).to have_css('.label--two_col .label_inner')
    expect(page).to have_css('.hinter-clicker')
    expect(page.evaluate_script('window.faeLoadRoots')).to eq(['document'])
  end

  scenario 'does not initialize the first page twice' do
    visit edit_admin_release_path(release)
    track_turbo
    eventually { expect(page).to have_css('.chosen-container') }

    expect(page.evaluate_script('window.faeLoadRoots')).to eq([])
    expect(page.evaluate_script("$('.label_inner').length === $('.input label').length")).to be true
  end

  scenario 'shows the flash message after a form is saved through Turbo' do
    visit edit_admin_release_path(release)
    track_turbo
    eventually { expect(page).to have_css('.chosen-container') }

    click_button 'Save'

    expect(page).to have_current_path(admin_releases_path)
    expect(page).to have_css('.toast-container .flash-toast', text: I18n.t('fae.save_notice'))
    expect(page.evaluate_script('window.faeDocumentMarker')).to be true
  end

  scenario 'does not accumulate listeners or jQuery data across visits' do
    visit edit_admin_release_path(release)
    track_turbo
    eventually { expect(page).to have_css('.chosen-container') }

    # The first round trip registers the once-only listeners; later ones must not add any
    turbo_visit fae.root_path
    turbo_visit edit_admin_release_path(release)
    baseline = page.evaluate_script(FOOTPRINT)

    4.times do
      turbo_visit fae.root_path
      turbo_visit edit_admin_release_path(release)
    end

    expect(page.evaluate_script(FOOTPRINT)).to eq(baseline)
  end

  scenario 'resets modal state when the page is replaced' do
    visit fae.root_path
    track_turbo
    page.execute_script('Fae.modals.modalOpen = true')

    turbo_visit admin_wines_path

    expect(page.evaluate_script('Fae.modals.modalOpen')).to be false
  end

  scenario 'initializes the contents of a turbo frame on its own' do
    visit fae.root_path
    track_turbo
    page.execute_script(<<~JS)
      var frame = document.createElement('turbo-frame')
      frame.id = 'test-frame'
      document.querySelector('#js-main-content').appendChild(frame)
      frame.dispatchEvent(new CustomEvent('turbo:frame-load', { bubbles: true }))
    JS

    expect(page.evaluate_script('window.faeLoadRoots')).to eq(['element'])
  end

  context 'after a visit that redirects (index, Add New, then the draft form)' do
    # Turbo dispatches before-render and render a second time for a redirected visit, without replacing the body,
    # so the live page must not be cleaned up on those. This is the path Add New takes.
    before do
      visit admin_beers_path
      track_turbo
      page.execute_script("window.confirm = function(message) { window.faeConfirms = (window.faeConfirms || []).concat([message]); return true }")

      find('a.add-button').click
      expect(page).to have_css('#js-header-cancel[data-draft="true"]')
      eventually { expect(controller_connected?('#js-header-cancel', 'fae-cancel')).to be true }
    end

    scenario 'keeps the jQuery handlers and widgets of the new page' do
      expect(page.evaluate_script('window.faeDocumentMarker')).to be true
      expect(page.evaluate_script("Object.keys($._data(document.querySelector('form'), 'events') || {}).sort().join()")).to include('submit')
      expect(page).to have_css('.chosen-container')

      page.find('#beer_aromas_chosen, .chosen-container', match: :first).click
      expect(page).to have_css('.chosen-container.chosen-with-drop')
    end

    scenario 'saves without asking whether to leave' do
      fill_in 'Name', with: 'A Beer'
      click_button 'Save'

      expect(page).to have_current_path(admin_beers_path)
      expect(page.evaluate_script('window.faeConfirms')).to be_nil
      expect(page.evaluate_script('window.faeDocumentMarker')).to be true
    end
  end

  context 'on a draft form' do
    before do
      visit new_admin_release_path
      eventually { expect(page).to have_css('#js-header-cancel[data-draft="true"]') }
      eventually { expect(controller_connected?('#js-header-cancel', 'fae-cancel')).to be true }
    end

    scenario 'asks before leaving through a Turbo visit and stays when declined' do
      dismiss_confirm do
        page.execute_script("setTimeout(function() { Turbo.visit('#{admin_wines_path}') }, 0)")
      end

      expect(page).to have_current_path(/releases\/\d+\/edit/)
    end

    scenario 'leaves when confirmed' do
      accept_confirm do
        page.execute_script("setTimeout(function() { Turbo.visit('#{admin_wines_path}') }, 0)")
      end

      expect(page).to have_current_path(admin_wines_path)
    end
  end
end
