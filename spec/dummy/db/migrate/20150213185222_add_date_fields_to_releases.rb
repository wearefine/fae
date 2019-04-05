class AddDateFieldsToReleases < ActiveRecord::Migration[4.2]
  def change
    add_column :releases, :release_date, :date
    add_column :releases, :show, :date
    add_column :releases, :hide, :date
  end
end
