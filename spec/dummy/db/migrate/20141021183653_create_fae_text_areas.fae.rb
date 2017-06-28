# This migration comes from fae (originally 20141021183047)
class CreateFaeTextAreas < ActiveRecord::Migration[4.2]
  def change
    create_table :fae_text_areas do |t|
      t.integer :contentable, polymorphic: true, index: true
      t.string :label
      t.text :content
      t.integer :position, default: 0
      t.boolean :on_stage, default: true
      t.boolean :on_prod, default: false

      t.timestamps
    end
  end
end
