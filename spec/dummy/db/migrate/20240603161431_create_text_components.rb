class CreateTextComponents < ActiveRecord::Migration[7.0]
  def change
    create_table :text_components do |t|
      t.string :name

      t.timestamps
    end
  end
end
