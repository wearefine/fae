class AddFeaturedToReleases < ActiveRecord::Migration
  def change
    add_column :releases, :featured, :boolean
  end
end
