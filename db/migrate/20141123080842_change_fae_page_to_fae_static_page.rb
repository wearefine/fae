class ChangeFaePageToFaeStaticPage < ActiveRecord::Migration
  def change
    rename_table :fae_pages, :fae_static_pages
  end
end
