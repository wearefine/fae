class AddPositionToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :position, :integer
  end
end
