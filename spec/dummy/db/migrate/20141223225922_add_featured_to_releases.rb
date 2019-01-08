class AddFeaturedToReleases < ActiveRecord::Migration[4.2]
  def change
    add_column :releases, :featured, :boolean
  end
end
