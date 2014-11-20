class DropLocations < ActiveRecord::Migration
  def change
    drop_table :locations
  end
end
