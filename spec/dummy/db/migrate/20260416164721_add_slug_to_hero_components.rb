class AddSlugToHeroComponents < ActiveRecord::Migration[7.0]
  def change
    add_column :hero_components, :slug, :string
  end
end
