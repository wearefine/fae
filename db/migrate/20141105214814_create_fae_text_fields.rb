class CreateFaeTextFields < ActiveRecord::Migration
  def change
    create_table :fae_text_fields do |t|
      t.references :contentable, polymorphic: true, index: true
      t.string :attatched_as, index: true
      t.string :label
      t.string :content
      t.integer :position, default: 0, index: true
      t.boolean :on_stage, default: true, index: true
      t.boolean :on_prod, default: false, index: true

      t.timestamps
    end

    add_index :fae_text_fields, :attached_as
    add_index :fae_text_fields, :position
    add_index :fae_text_fields, :on_stage
    add_index :fae_text_fields, :on_prod
  end
end