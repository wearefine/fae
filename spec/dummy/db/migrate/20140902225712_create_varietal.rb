class CreateVarietal < ActiveRecord::Migration
  def change
    create_table :varietals do |t|
      t.string :name

      t.boolean :on_stage, default: true
      t.boolean :on_prod, default: false
      t.integer :position

      t.timestamps
    end
  end
end
