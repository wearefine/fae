class AddSEOFieldsToRelease < ActiveRecord::Migration[5.0]
  def change
    add_column :releases, :seo_title, :string
    add_column :releases, :seo_description, :string
  end
end
