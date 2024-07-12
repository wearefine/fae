require 'spec_helper'

feature 'Clone record' do

  context 'from an edit form' do

    scenario 'should duplicate the record and redirect to edit form', js: true do
      release = FactoryBot.create(:release, name: 'Ima Release', vintage: '2012', price: 13, varietal_id: 2, show: Date.today)
      admin_login
      visit edit_admin_release_path(release)
      click_link 'Clone'

      # support/async_helper.rb
      eventually {
        cloned_release = Release.find_by_name('Ima Release-2')
        expect(cloned_release).to_not be_nil
        expect(current_path).to eq(edit_admin_release_path(cloned_release))
        expect(find_field('release_name').value).to eq(cloned_release.name)

        # only whiteliested attributes should be cloned
        expect(cloned_release.slug).to          eq(release.slug)
        expect(cloned_release.intro).to         eq(release.intro)
        expect(cloned_release.body).to          eq(release.body)
        expect(cloned_release.wine_id).to       eq(release.wine_id)
        expect(cloned_release.release_date).to  eq(release.release_date)

        # other's should not
        expect(cloned_release.vintage).to     eq(nil)
        expect(cloned_release.price).to       eq(nil)
        expect(cloned_release.varietal_id).to eq(nil)
        expect(cloned_release.show).to        eq(nil)
      }
    end

    scenario 'should clone associations', js: true do
      release = FactoryBot.create(:release, name: 'Ima Release')
      aroma = FactoryBot.create(:aroma, release: release)
      event_1 = FactoryBot.create(:event)
      event_2 = FactoryBot.create(:event)
      release.events << event_1
      release.events << event_2

      admin_login
      visit edit_admin_release_path(release)
      click_link 'Clone'

      # support/async_helper.rb
      eventually {
        cloned_release = Release.find_by_name('Ima Release-2')

        # belongs_to just copies the foreign key
        expect(cloned_release.wine).to eq(release.wine)

        # has_many and has_one duplicates the associated object
        expect(cloned_release.aromas.first).to_not eq(release.aromas.first)
        expect(cloned_release.aromas.first.name).to eq(release.aromas.first.name)

        # habtm duplicates the join records
        expect(cloned_release.events.reverse).to eq(release.events)
        # Case insensitive matching in case labels become text-transform: uppercase
        expect(page).to have_selector('.release_events', text: /#{event_1.name}/i)
        expect(page).to have_selector('.release_events', text: /#{event_2.name}/i)
      }
    end

  end

  # context 'from fae_clone_button' do

  #   scenario 'should duplicate the record and redirect to edit form', js: true do
  #     release = FactoryBot.create(:release, name: 'Ima Release', vintage: '2012', price: 13, varietal_id: 2, show: Date.today)
  #     admin_login
  #     visit admin_releases_path
  #     page.find('a.table-action[title="Clone"]').click

  #     # support/async_helper.rb
  #     eventually {
  #       cloned_release = Release.find_by_name('Ima Release-2')
  #       expect(cloned_release).to_not be_nil
  #       expect(current_path).to eq(edit_admin_release_path(cloned_release))
  #       expect(find_field('release_name').value).to eq(cloned_release.name)
  #     }
  #   end

  #   scenario 'should set on_prod when true to false' do
  #     release = FactoryBot.create(:release, name: 'Ima Release', vintage: '2012', on_prod: true, price: 13, varietal_id: 2, show: Date.today)
  #     admin_login
  #     visit admin_releases_path
  #     page.find('a.table-action[title="Clone"]').click

  #     eventually {
  #       expect(find_field('release_on_prod_false').value).to eq('false')
  #     }

  #   end

  # end

end
