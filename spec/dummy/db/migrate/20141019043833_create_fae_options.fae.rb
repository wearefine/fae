# This migration comes from fae (originally 20141017194616)
class CreateFaeOptions < ActiveRecord::Migration[4.2]
  def change
    create_table :fae_options do |t|
      t.string :title
      t.string :time_zone
      t.string :colorway
      t.string :stage_url
      t.string :live_url
      t.integer :singleton_guard

      t.timestamps
    end

    add_index :fae_options, :singleton_guard, unique: true
  end
end