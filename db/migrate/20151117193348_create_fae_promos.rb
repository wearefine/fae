class CreateFaePromos < ActiveRecord::Migration
  def change
    create_table :fae_promos do |t|
      t.string :headline
      t.text :body
      t.string :link
      t.label :link

      t.timestamps null: false
    end
  end
end
