class AddReleaseIdToAromas < ActiveRecord::Migration
  def change
    add_reference :aromas, :release, index: true
  end
end
