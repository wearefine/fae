require 'spec_helper'

feature 'slug' do

  context "when there's only on slugger" do
    scenario 'should slug the slugger', js: true do
      admin_login
      visit new_admin_release_path

      fill_in 'Name', with: "!St. John's @#!*  What?"
      expect(find_field('Slug').value).to eq('st-johns')
    end
  end

  context "when there's multiple sluggers" do
    scenario 'should slug all sluggers', js: true do
      admin_login
      visit new_admin_release_path

      fill_in 'Name', with: "So what'cho what'cho"
      fill_in 'Vintage', with: "What'cho want?!"
      expect(find_field('Slug').value).to eq('so-whatcho-wha-whatcho-want')
    end
  end

  context "when there's a selector slugger" do
    scenario 'should slug all sluggers', js: true do
      varietal = FactoryGirl.create(:varietal, name: "Monkey")
      admin_login
      visit new_admin_release_path

      fill_in 'Name', with: "George"
      page.find('#release_varietal_id_chosen').click
      page.find('#release_varietal_id_chosen .active-result', text: varietal.name).click
      expect(find_field('Slug').value).to eq('george-monkey')
    end
  end

  context "when there's a nested slugger" do
    scenario 'should allow adding slugs to nested items', js: true do
      release = FactoryGirl.create(:release, name: 'poop', slug: 'release-name-slug')

      admin_login
      visit edit_admin_release_path(release)

      click_link 'Add Aroma'

      within(:css, 'form#new_aroma') do
        fill_in 'Name', with: 'My Brand New Smell!'
        expect(page.find('form#new_aroma .slug').value).to eq('my-brand-new-smell')
        click_button('Create Aroma')
      end

    end
  end

end