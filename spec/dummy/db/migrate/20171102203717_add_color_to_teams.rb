class AddColorToTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :color, :string
  end
end
