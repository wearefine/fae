class MoveColor < ActiveRecord::Migration[5.0]
  def change
    remove_column :teams, :color
    add_column :releases, :color, :string
  end
end
