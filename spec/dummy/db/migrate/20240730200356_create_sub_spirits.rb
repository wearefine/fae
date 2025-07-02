class CreateSubSpirits < ActiveRecord::Migration[7.0]
  def change
    create_table :sub_spirits do |t|
      t.string :name, index: true
      t.integer :spirit_id, index: true

      t.timestamps
    end
  end
end
