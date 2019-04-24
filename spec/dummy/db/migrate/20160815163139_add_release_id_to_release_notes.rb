class AddReleaseIdToReleaseNotes < ActiveRecord::Migration[4.2]
  def change
    add_reference :release_notes, :release, index: true
  end
end
