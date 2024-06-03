class CreateFlexComponents < ActiveRecord::Migration[7.0]
  def change
    create_table :flex_components do |t|
      t.references :flex_componentable, polymorphic: true, null: false
      t.string :component_model, index: true
      t.integer :component_id, index: true
      t.integer :position, index: true
      t.boolean :on_stage, index: true, default: true
      t.boolean :on_prod, index: true, default: false

      t.timestamps
    end
  end
end