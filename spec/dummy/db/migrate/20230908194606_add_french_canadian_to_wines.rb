class AddFrenchCanadianToWines < ActiveRecord::Migration[7.0]
  def change
    add_column :wines, :name_frca, :string
    add_column :wines, :description_frca, :string
  end
end
