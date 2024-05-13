require 'spec_helper'

# 2024-04-29 This test is flickering (and has been for a while). I've confirmed the behavior being tested is working as expected.
feature 'sortable' do

  scenario 'should allow reordering of items', js: true do
    acclaim_1 = FactoryBot.create(:acclaim, publication: 'acclaim one', position: 1)
    acclaim_2 = FactoryBot.create(:acclaim, publication: 'acclaim two', position: 2)
    acclaim_3 = FactoryBot.create(:acclaim, publication: 'acclaim three', position: 3)
    acclaim_4 = FactoryBot.create(:acclaim, publication: 'acclaim four', position: 4)

    admin_login
    visit admin_acclaims_path

    expect(Acclaim.order(:position)).to eq([acclaim_1, acclaim_2, acclaim_3, acclaim_4])

    handle = find("#acclaim_#{acclaim_4.id} .sortable-handle")
    target = find("#acclaim_#{acclaim_1.id} .sortable-handle")
    handle.drag_to(target)

    eventually {
      expect(Acclaim.order(:position)).to eq([acclaim_4, acclaim_1, acclaim_2, acclaim_3])
    }
  end

end
