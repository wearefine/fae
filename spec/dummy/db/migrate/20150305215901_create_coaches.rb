class CreateCoaches < ActiveRecord::Migration
  def change
    create_table :coaches do |t|
      t.string :first_name
      t.string :last_name
      t.string :role
      t.text :bio
      t.references :team, index: true

      t.timestamps
    end
  end
end
