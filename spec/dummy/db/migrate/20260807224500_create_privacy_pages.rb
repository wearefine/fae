class CreatePrivacyPages < ActiveRecord::Migration[7.0]
  def change
    create_table :privacy_pages do |t|
      t.string :title
      t.text :headline
      t.text :body
      t.text :body_2
      t.string :seo_title
      t.text :seo_description
      t.string :social_media_title
      t.text :social_media_description
      t.boolean :draft, default: false

      t.timestamps
    end
  end
end
