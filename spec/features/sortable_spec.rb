require 'spec_helper'

feature 'sortable' do

  scenario 'should allow reordering of items', js: true do
    acclaim_1 = FactoryGirl.create(:acclaim, publication: 'acclaim one', position: 1)
    acclaim_2 = FactoryGirl.create(:acclaim, publication: 'acclaim two', position: 2)
    acclaim_3 = FactoryGirl.create(:acclaim, publication: 'acclaim three', position: 3)
    acclaim_4 = FactoryGirl.create(:acclaim, publication: 'acclaim four', position: 4)

    admin_login
    visit admin_acclaims_path

    expect(Acclaim.order(:position)).to eq([acclaim_1, acclaim_2, acclaim_3, acclaim_4])

    handle = find("#acclaim_#{acclaim_4.id} .arrange-handle")
    target = find("#acclaim_#{acclaim_1.id} .arrange-handle")
    handle.drag_to(target)

    eventually {
      expect(Acclaim.order(:position)).to eq([acclaim_4, acclaim_1, acclaim_2, acclaim_3])
    }
  end

end
