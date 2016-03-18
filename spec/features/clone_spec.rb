require 'spec_helper'

feature 'Clone record' do

  context 'from an edit form' do

    scenario 'should duplicate the record and redirect to edit form', js: true do
      release = FactoryGirl.create(:release, name: 'Ima Release', vintage: '2012', price: 13, varietal_id: 2, show: Date.today)
      admin_login
      visit edit_admin_release_path(release)
      click_link 'Clone'

      # support/async_helper.rb
      eventually {
        cloned_release = Release.find_by_name('Ima Release-2')
        expect(cloned_release).to_not be_nil
        expect(current_path).to eq(edit_admin_release_path(cloned_release))
        expect(find_field('Name').value).to eq(cloned_release.name)

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
      release = FactoryGirl.create(:release, name: 'Ima Release')
      aroma = FactoryGirl.create(:aroma, release: release)
      event_1 = FactoryGirl.create(:event)
      event_2 = FactoryGirl.create(:event)
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
        expect(cloned_release.events).to eq(release.events)
        expect(page.find('.release_events')).to have_content(event_1.name)
        expect(page.find('.release_events')).to have_content(event_2.name)
      }
    end

  end

  context 'from fae_clone_button' do

    scenario 'should duplicate the record and redirect to edit form', js: true do
      release = FactoryGirl.create(:release, name: 'Ima Release', vintage: '2012', price: 13, varietal_id: 2, show: Date.today)
      admin_login
      visit admin_releases_path
      page.find('.table-action.-clone').click

      # support/async_helper.rb
      eventually {
        cloned_release = Release.find_by_name('Ima Release-2')
        expect(cloned_release).to_not be_nil
        expect(current_path).to eq(edit_admin_release_path(cloned_release))
        expect(find_field('Name').value).to eq(cloned_release.name)
      }
    end

    scenario 'should set on_prod when true to false' do
      release = FactoryGirl.create(:release, name: 'Ima Release', vintage: '2012', on_prod: true, price: 13, varietal_id: 2, show: Date.today)
      admin_login
      visit admin_releases_path
      page.find('.table-action.-clone').click

      eventually {
        expect(find_field('release_on_prod_false').value).to eq('false')
      }

    end

  end

end
