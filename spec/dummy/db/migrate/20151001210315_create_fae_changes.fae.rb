# This migration comes from fae (originally 20150930224821)
class CreateFaeChanges < ActiveRecord::Migration
  def change
    create_table :fae_changes do |t|
      t.integer :changeable_id
      t.string :changeable_type
      t.integer :user_id
      t.string :change_type
      t.text :updated_attributes

      t.timestamps null: false
    end

    add_index :fae_changes, :changeable_id
    add_index :fae_changes, :changeable_type
    add_index :fae_changes, :user_id
  end
end
