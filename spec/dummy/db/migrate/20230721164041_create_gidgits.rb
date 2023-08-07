class CreateGidgits < ActiveRecord::Migration[7.0]
  def change
    create_table :gidgits do |t|
      t.string :name

      t.timestamps
    end
  end
end
