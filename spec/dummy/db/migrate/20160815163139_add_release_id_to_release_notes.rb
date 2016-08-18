class AddReleaseIdToReleaseNotes < ActiveRecord::Migration
  def change
    add_reference :release_notes, :release, index: true
  end
end
