class AddDescriptionToReleases < ActiveRecord::Migration
  def change
    add_column :releases, :description, :text
  end
end
