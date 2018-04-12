class CreateFaeRoles < ActiveRecord::Migration[4.2]
  def change
    create_table :fae_roles do |t|
      t.string :name
      t.integer :position

      t.timestamps
    end
  end
end
