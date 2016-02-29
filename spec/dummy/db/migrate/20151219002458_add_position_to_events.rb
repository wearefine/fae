class AddPositionToEvents < ActiveRecord::Migration
  def change
    add_column :events, :position, :integer
  end
end
