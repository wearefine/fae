class AddPositionToPeople < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :position, :integer
  end
end
