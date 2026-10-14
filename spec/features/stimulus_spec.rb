require 'spec_helper'

feature 'Stimulus via the Fae importmap' do

  scenario 'loads Fae and host app modules from the Fae importmap', js: true do
    admin_login
    visit fae.root_path

    importmap = JSON.parse(find('script[type="importmap"]', visible: false).text(:all))['imports']
    expect(importmap.keys).to include('fae', '@hotwired/stimulus', 'fae/controllers/contrast_controller', 'fae_custom', 'fae_custom/controllers/greeting_controller')

    eventually { expect(page.evaluate_script('typeof window.Stimulus')).to eq('object') }
  end

  scenario 'connects host app controllers to markup added after page load', js: true do
    admin_login
    visit fae.root_path
    eventually { expect(page.evaluate_script('typeof window.Stimulus')).to eq('object') }

    page.execute_script(<<~JS)
      document.querySelector('#js-main-content').insertAdjacentHTML('beforeend',
        '<div id="greeting" data-controller="dummy-greeting" data-dummy-greeting-name-value="Host App"></div>')
    JS

    expect(page).to have_css('#greeting', text: 'Hello, Host App')
  end

  context 'fae-contrast controller' do
    scenario 'uses a dark foreground on a light highlight color', js: true do
      Fae::Option.instance.update_column(:colorway, 'FFFF00')
      admin_login
      visit fae.root_path

      eventually { expect(foreground_color).to eq('#000') }
    end

    scenario 'uses a light foreground on a dark highlight color', js: true do
      Fae::Option.instance.update_column(:colorway, '000080')
      admin_login
      visit fae.root_path

      eventually { expect(foreground_color).to eq('#fff') }
    end
  end

  context 'fae-language controller' do
    before do
      admin_login
      visit new_admin_wine_path
      eventually { expect(controller_connected?('#js-language', 'fae-language')).to be true }

      page.execute_script(<<~JS)
        window.preferencePosts = 0
        const count = (url) => { if (String(url).includes('language_preference')) window.preferencePosts++ }
        const fetch = window.fetch
        window.fetch = function(url) { count(url); return fetch.apply(this, arguments) }
        const post = $.post
        $.post = function(url) { count(url); return post.apply(this, arguments) }
      JS
    end

    scenario 'toggles fields and saves the preference from a chosen selection', js: true do
      find('#js_language_chosen').click
      find('#js_language_chosen li', text: 'Chinese').click

      expect(page).to have_selector('div[data-language=en]')
      expect(page).to have_selector('div[data-language=zh]')
      expect(page).to_not have_selector('div[data-language=frca]')
      eventually { expect(Fae::User.find_by(first_name: 'Admin').language).to eq('zh') }
      expect(page.evaluate_script('window.preferencePosts')).to eq(1)
    end

    scenario 'responds to native change events', js: true do
      page.execute_script(<<~JS)
        const select = document.getElementById('js-language')
        select.value = 'frca'
        select.dispatchEvent(new Event('change', { bubbles: true }))
      JS

      expect(page).to have_selector('div[data-language=frca]')
      expect(page).to_not have_selector('div[data-language=zh]')
      eventually { expect(Fae::User.find_by(first_name: 'Admin').language).to eq('frca') }
      expect(page.evaluate_script('window.preferencePosts')).to eq(1)
    end
  end

  context 'fae-filtering controller' do
    before do
      wine = FactoryBot.create(:wine, name_en: 'Red')
      (1..7).each { |n| FactoryBot.create(:release, name: "Release #{n}", wine: wine) }
      admin_login
    end

    scenario 'replaces legacy filtering on fae_filter_form pages', js: true do
      visit admin_releases_path
      eventually { expect(controller_connected?('.js-filter-form', 'fae-filtering')).to be true }

      expect(page.evaluate_script('typeof Fae.form.filtering.fry')).to eq('undefined')
    end

    scenario 'paginates through the filter endpoint', js: true do
      visit admin_releases_path
      eventually { expect(controller_connected?('.js-filter-form', 'fae-filtering')).to be true }
      expect(page).to have_css('tbody tr', count: 5)

      within('.pagination') { click_link '2' }

      expect(page).to have_css('tbody tr', count: 2)
      expect(page).to have_current_path(/#\?.*page=2/, url: true)
    end

    scenario 'searches on native form submission and resets', js: true do
      visit admin_releases_path
      eventually { expect(controller_connected?('.js-filter-form', 'fae-filtering')).to be true }

      fill_in 'filter_search', with: 'Release 7'
      page.execute_script("document.querySelector('.js-filter-form').requestSubmit()")

      expect(page).to have_css('tbody tr', count: 1)
      expect(page).to have_current_path(admin_releases_path, ignore_query: true)

      find('.js-reset-btn').click
      expect(page).to have_field('filter_search', with: '')
      expect(page).to have_css('tbody tr', count: 5)
    end

    scenario 'restores saved filters from the cookie', js: true do
      visit admin_releases_path + '#?page=2'
      expect(page).to have_css('tbody tr', count: 2)

      visit admin_releases_path
      expect(page).to have_current_path(/#\?page=2/, url: true)
      expect(page).to have_css('tbody tr', count: 2)
    end
  end

  def foreground_color
    page.evaluate_script("document.body.style.getPropertyValue('--foreground-color')")
  end

end
