class AddRegionTypeToWinemaker < ActiveRecord::Migration
  def change
    add_column :winemakers, :region_type, :integer
  end
end
