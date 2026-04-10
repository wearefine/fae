class CreateKnobs < ActiveRecord::Migration[7.0]
  def change
    create_table :knobs do |t|
      t.string :title

      t.timestamps
    end
  end
end
