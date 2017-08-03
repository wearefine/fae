require 'rails_helper'

describe 'cloning assets' do

  it 'should clone fae assets' do

    release = FactoryGirl.create(:release, name: 'Ima Release')
    bottle_shot = FactoryGirl.create(:fae_image, imageable_type: 'Release', imageable_id: release.id, attached_as: 'bottle_shot')
    label_pdf = FactoryGirl.create(:fae_file, fileable_type: 'Release', fileable_id: release.id, attached_as: 'label_pdf')

    admin_login
    post admin_releases_path(from_existing: release.id)

    cloned_release = Release.find_by_name('Ima Release-2')

    expect(cloned_release.bottle_shot).to_not eq(bottle_shot)
    expect(cloned_release.bottle_shot.asset.file.filename).to eq(bottle_shot.asset.file.filename)

    expect(cloned_release.label_pdf).to_not eq(label_pdf)
    expect(cloned_release.label_pdf.asset.file.filename).to eq(label_pdf.asset.file.filename)

  end

end
