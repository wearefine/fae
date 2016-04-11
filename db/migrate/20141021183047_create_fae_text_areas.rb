class CreateFaeTextAreas < ActiveRecord::Migration
  def change
    create_table :fae_text_areas do |t|
      t.string :label
      t.text :content
      t.integer :position, default: 0, index: true
      t.boolean :on_stage, default: true, index: true
      t.boolean :on_prod, default: false, index: true
      t.integer :contentable_id, index: true
      t.string :contentable_type, index: true
      t.string :attached_as, index: true

      t.timestamps
    end
  end
end
