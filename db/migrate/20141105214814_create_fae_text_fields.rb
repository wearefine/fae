class CreateFaeTextFields < ActiveRecord::Migration[4.2]
  def change
    create_table :fae_text_fields do |t|
      t.references :contentable, polymorphic: true, index: true
      t.string :attached_as, index: true
      t.string :label
      t.string :content
      t.integer :position, default: 0, index: true
      t.boolean :on_stage, default: true, index: true
      t.boolean :on_prod, default: false, index: true

      t.timestamps
    end
  end
end
