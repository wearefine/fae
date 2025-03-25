class CreateFaeSites < ActiveRecord::Migration[7.0]
  def change
    create_table :fae_sites do |t|
      t.string :name, index: true
      t.string :netlify_site
      t.string :netlify_site_id

      t.timestamps
    end
  end
end
