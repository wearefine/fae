class CreateWidgets < ActiveRecord::Migration[7.0]
  def change
    create_table :widgets do |t|
      t.string :name
      t.integer :position, index: true
      t.boolean :on_stage, index: true, default: true
      t.boolean :on_prod, index: true, default: false
      t.boolean :draft

      t.timestamps
    end
    add_index :widgets, :draft
  end
end
