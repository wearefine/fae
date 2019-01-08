class AddWeightToReleases < ActiveRecord::Migration[4.2]
  def change
    add_column :releases, :weight, :string
  end
end
