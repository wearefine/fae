class AddDescriptionToReleases < ActiveRecord::Migration[4.2]
  def change
    add_column :releases, :description, :text
  end
end
