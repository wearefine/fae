require 'spec_helper'

feature 'slug' do

  context "when there's only on slugger" do
    scenario 'should slug the slugger', js: true do
      admin_login
      visit new_admin_release_path

      fill_in 'Name', with: "!St. John's @#!*  What?"
      expect(find_field('Slug').value).to eq('st-johns-what')
    end
  end

    context "when there's multiple sluggers" do
    scenario 'should slug all sluggers', js: true do
      admin_login
      visit new_admin_release_path

      fill_in 'Name', with: "What'cho want?"
      fill_in 'Vintage', with: "So what'cho want?!"
      expect(find_field('Slug').value).to eq('whatcho-want-so-whatcho-want')
    end
  end

end