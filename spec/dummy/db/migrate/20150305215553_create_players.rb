class CreatePlayers < ActiveRecord::Migration[4.2]
  def change
    create_table :players do |t|
      t.string :first_name
      t.string :last_name
      t.string :number
      t.text :bio
      t.references :team, index: true

      t.timestamps
    end
  end
end
