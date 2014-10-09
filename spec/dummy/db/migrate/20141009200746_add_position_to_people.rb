class AddPositionToPeople < ActiveRecord::Migration
  def change
    add_column :people, :position, :integer
  end
end
