class AddSlugToAromas < ActiveRecord::Migration
  def change
    add_column :aromas, :slug, :string
  end
end
