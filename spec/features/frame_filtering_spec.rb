require 'spec_helper'

# Filtering, sorting and paging inside a fae_filter_frame: Turbo swaps the frame in place, the URL carries the whole
# state, and the document (and with it the page's scripts, scroll and open widgets) is never reloaded.
[false, true].each do |drive|
  feature "Filter frame with Turbo Drive #{drive ? 'on' : 'off'}", js: true do
    let!(:events) { [FactoryBot.create(:event, name: 'Gala'), FactoryBot.create(:event, name: 'Tasting')] }

    around do |example|
      original = Fae.turbo_drive
      Fae.turbo_drive = drive
      example.run
      Fae.turbo_drive = original
    end

    before do
      admin_login
      %w[Alpha Bravo Charlie Delta Echo Foxtrot Golf].each_with_index do |name, i|
        FactoryBot.create(:person, name: name, event: events[i % 2], position: i + 1)
      end
    end

    def open_people(path = admin_people_path)
      visit path
      eventually { expect(page).to have_css('turbo-frame#people_results .chosen-container') }
      page.execute_script('window.faeDocumentMarker = true')
    end

    def names
      all('#people_results tbody tr td:first-child').map(&:text)
    end

    def expect_frame_navigation
      expect(page.evaluate_script('window.faeDocumentMarker')).to be true
    end

    scenario 'searches in place and puts the search in the URL' do
      open_people

      find('#filter_search').fill_in(with: 'Bravo')
      find('#filter_search').send_keys(:enter)

      expect(page).to have_css('#people_results tbody tr', count: 1)
      expect(names).to eq(['Bravo'])
      expect(page).to have_current_path(/filter%5Bsearch%5D=Bravo/, url: false)
      expect(page).to have_field('filter_search', with: 'Bravo')
      expect_frame_navigation
    end

    scenario 'filters with a select and re-initializes it for the next change' do
      open_people

      page.find('#filter_event_chosen').click
      page.find('#filter_event_chosen .active-result', text: 'Tasting').click

      expect(page).to have_css('#people_results tbody tr', count: 3)
      expect(names).to eq(%w[Bravo Delta Foxtrot])
      expect(page).to have_css('#people_results .chosen-container', count: 1)
      expect(page).to have_css('#filter_event_chosen .chosen-single span', text: 'Tasting')
      expect_frame_navigation

      # the re-rendered select is live
      page.find('#filter_event_chosen').click
      page.find('#filter_event_chosen .active-result', text: 'Gala').click

      expect(page).to have_css('#people_results tbody tr', count: 4)
      expect(names).to eq(%w[Alpha Charlie Echo Golf])
    end

    scenario 'sorts by clicking a header, toggling the direction' do
      open_people

      find('th[data-sort="name"]').click
      expect(page).to have_css('th[data-sort="name"].-asc')
      expect(page).to have_current_path(/sort_by=name&sort_direction=asc/, url: false)
      expect(names).to eq(%w[Alpha Bravo Charlie Delta Echo])

      find('th[data-sort="name"]').click
      expect(page).to have_css('th[data-sort="name"].-desc')
      expect(names).to eq(%w[Golf Foxtrot Echo Delta Charlie])
      expect_frame_navigation
    end

    scenario 'pages in place, and a filter change keeps the sort' do
      open_people

      find('th[data-sort="name"]').click
      expect(page).to have_css('th[data-sort="name"].-asc')

      within('.pagination') { click_link '2' }
      expect(page).to have_current_path(/page=2/, url: false)
      expect(page).to have_css('#people_results tbody tr', count: 2)
      expect(names).to eq(%w[Foxtrot Golf])
      expect_frame_navigation

      page.find('#filter_event_chosen').click
      page.find('#filter_event_chosen .active-result', text: 'Gala').click

      expect(page).to have_css('#people_results tbody tr', count: 4)
      expect(names).to eq(%w[Alpha Charlie Echo Golf])
      expect(page).to have_css('th[data-sort="name"].-asc')
      expect(page).not_to have_current_path(/page=2/, url: false)
    end

    scenario 'opens a filtered, sorted, paged URL straight to that state' do
      open_people(admin_people_path(filter: { event: events.last.id }, sort_by: 'name', sort_direction: 'desc'))

      expect(names).to eq(%w[Foxtrot Delta Bravo])
      expect(page).to have_css('#filter_event_chosen .chosen-single span', text: 'Tasting')
      expect(page).to have_css('th[data-sort="name"].-desc')
      expect(page).to have_link('Reset Search')
    end

    scenario 'resets back to the full list, clearing the form' do
      open_people

      find('#filter_search').fill_in(with: 'Bravo')
      find('#filter_search').send_keys(:enter)
      expect(page).to have_css('#people_results tbody tr', count: 1)

      click_link 'Reset Search'

      expect(page).to have_css('#people_results tbody tr', count: 5)
      expect(page).to have_field('filter_search', with: '')
      expect(page).to have_current_path(admin_people_path, ignore_query: false)
      expect_frame_navigation
    end

    scenario 'keeps the form when nothing matches so the search can be changed' do
      open_people

      find('#filter_search').fill_in(with: 'zzz')
      find('#filter_search').send_keys(:enter)

      expect(page).to have_content('No items found')
      expect(page).to have_field('filter_search', with: 'zzz')
      expect(page).to have_link('Reset Search')
    end

    scenario 'follows the browser back button through the states' do
      open_people

      find('th[data-sort="name"]').click
      expect(page).to have_css('th[data-sort="name"].-asc')
      within('.pagination') { click_link '2' }
      expect(page).to have_css('#people_results tbody tr', count: 2)

      page.go_back
      expect(page).to have_css('#people_results tbody tr', count: 5)
      expect(names).to eq(%w[Alpha Bravo Charlie Delta Echo])
      expect(page).to have_css('th[data-sort="name"].-asc')
    end

    scenario 'sends links and buttons in the frame to the whole page' do
      open_people

      click_link 'Alpha'

      expect(page).to have_current_path(/people\/\d+\/edit/)
      expect(page).to have_field('person_name', with: 'Alpha')
    end

    scenario 'deletes a row with jquery_ujs from inside the frame' do
      open_people

      accept_confirm { first('#people_results a[data-method="delete"]').click }

      eventually { expect(Person.count).to eq(6) }
      expect(page).to have_current_path(admin_people_path)
    end
  end
end
