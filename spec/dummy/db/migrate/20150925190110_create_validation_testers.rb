class CreateValidationTesters < ActiveRecord::Migration
  def change
    create_table :validation_testers do |t|
      t.string :name
      t.string :slug
      t.string :second_slug
      t.string :email
      t.string :url
      t.string :phone
      t.string :zip
      t.string :canadian_zip
      t.string :youtube_url

      t.timestamps null: false
    end
  end
end
