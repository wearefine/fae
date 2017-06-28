class CreateAromas < ActiveRecord::Migration[4.2]
  def change
    create_table :aromas do |t|
      t.string :name
      t.text :description
      t.integer :position
      t.boolean :live

      t.timestamps
    end
  end
end
