class CreateBeers < ActiveRecord::Migration[5.0]
  def change
    create_table :beers do |t|
      t.string :name
      t.string :seo_title
      t.string :seo_description
      t.boolean :on_stage
      t.boolean :on_prod

      t.timestamps
    end
  end
end
