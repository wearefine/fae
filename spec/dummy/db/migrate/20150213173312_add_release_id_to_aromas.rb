class AddReleaseIdToAromas < ActiveRecord::Migration[4.2]
  def change
    add_reference :aromas, :release, index: true
  end
end
