class AddIsSomethingToReleases < ActiveRecord::Migration[5.2]
  def change
  	add_column :releases, :is_something, :boolean, default: false
  end
end
