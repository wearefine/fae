class AddRegionTypeToWinemaker < ActiveRecord::Migration[4.2]
  def change
    add_column :winemakers, :region_type, :integer
  end
end
