class AddWeightToReleases < ActiveRecord::Migration
  def change
    add_column :releases, :weight, :string
  end
end
