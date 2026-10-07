class CreateSingletonPages < ActiveRecord::Migration[7.0]
  def change
    create_table :singleton_pages do |t|
      t.string :name
      t.string :slug
      t.text :body

      t.timestamps
    end
  end
end
