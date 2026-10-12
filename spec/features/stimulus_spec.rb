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

  def foreground_color
    page.evaluate_script("document.body.style.getPropertyValue('--foreground-color')")
  end

end
