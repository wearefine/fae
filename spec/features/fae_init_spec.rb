require 'spec_helper'

feature 'Fae.init' do
  # Counts jQuery handlers on the targets legacy modules bind to, and the elements they build
  FOOTPRINT_JS = <<~JS.freeze
    (function() {
      var handlers = 0;
      $(document).add(window).add(document.body).add('#js-main-content').add('form').add('#js-header-cancel')
        .each(function() {
          var events = $._data(this, 'events') || {};
          Object.keys(events).forEach(function(type) { handlers += events[type].length; });
        });

      return {
        handlers: handlers,
        chosen: $('.chosen-container').length,
        counters: $('.counter').length,
        hinters: $('.hinter-clicker').length,
        labelInners: $('.label_inner').length,
        stickyHeaders: $('.sticky-table-header').length
      };
    })()
  JS

  before(:each) do
    admin_login
  end

  scenario 'running twice does not bind handlers or build widgets again', js: true do
    release = FactoryBot.create(:release, name: 'Test Release')
    visit edit_admin_release_path(release)
    eventually { expect(page.evaluate_script('typeof Fae.init')).to eq('function') }
    wait_for_animations

    before = page.evaluate_script(FOOTPRINT_JS)
    expect(before['chosen']).to be > 0
    expect(before['hinters']).to be > 0
    expect(before['labelInners']).to be > 0

    page.execute_script('Fae.init(); Fae.init(document)')

    expect(page.evaluate_script(FOOTPRINT_JS)).to eq(before)
  end

  scenario 'dispatches fae:load with the initialized root', js: true do
    visit fae.root_path
    eventually { expect(page.evaluate_script('typeof Fae.init')).to eq('function') }

    result = page.evaluate_async_script(<<~JS)
      var done = arguments[arguments.length - 1];
      var root = document.createElement('div');
      document.querySelector('#js-main-content').appendChild(root);

      document.addEventListener('fae:load', function(e) {
        done({ isRoot: e.detail.root === root, target: e.target === root });
      }, { once: true });

      Fae.init(root);
    JS

    expect(result).to eq('isRoot' => true, 'target' => true)
  end

  scenario 'initializes markup injected after page load', js: true do
    visit fae.root_path
    eventually { expect(page.evaluate_script('typeof Fae.init')).to eq('function') }

    page.execute_script(<<~JS)
      var wrapper = document.createElement('div');
      wrapper.id = 'injected';
      wrapper.innerHTML =
        '<div class="input select"><label for="injected_select">Pick one<span class="helper_text">Helper</span></label>' +
        '<select id="injected_select"><option value="a">A</option><option value="b">B</option></select></div>';
      document.querySelector('#js-main-content').appendChild(wrapper);
      Fae.init(wrapper);
    JS

    expect(page).to have_css('#injected .label--two_col .label_inner', text: 'Pick one')
    expect(page).to have_css('#injected .chosen-container')

    page.execute_script("Fae.init($('#injected'))")

    expect(page).to have_css('#injected .chosen-container', count: 1)
    expect(page).to have_css('#injected .label_inner', count: 1)
  end

  scenario 'registers window and document listeners once across repeated init', js: true do
    release = FactoryBot.create(:release, name: 'Test Release')
    visit edit_admin_release_path(release)
    eventually { expect(page.evaluate_script('typeof Fae.init')).to eq('function') }

    page.execute_script(<<~JS)
      window.faeFchCounts = function() { return [FCH.scroll.length, FCH.resize.length, FCH.load.length].join(','); };
    JS
    before = page.evaluate_script('window.faeFchCounts()')

    page.execute_script('Fae.init(); Fae.init()')

    expect(page.evaluate_script('window.faeFchCounts()')).to eq(before)
  end
end
