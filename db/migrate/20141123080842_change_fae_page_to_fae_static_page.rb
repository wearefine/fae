class ChangeFaePageToFaeStaticPage < ActiveRecord::Migration
  def change
    add_column :fae_pages, :subclass, :string
    rename_table :fae_pages, :fae_static_pages
  end
end
