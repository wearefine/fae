class AddSlugToAromas < ActiveRecord::Migration[4.2]
  def change
    add_column :aromas, :slug, :string
  end
end
