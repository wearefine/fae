class CreateFaeSeoSets < ActiveRecord::Migration[7.0]
  def change
    create_table :fae_seo_sets do |t|
      t.string :seo_title
      t.text :seo_description
      t.string :social_media_title
      t.text :social_media_description
      t.references :seo_setable, polymorphic: true, index: true

      t.timestamps
    end
  end
end
