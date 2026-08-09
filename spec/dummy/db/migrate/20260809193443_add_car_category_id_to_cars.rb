class AddCarCategoryIdToCars < ActiveRecord::Migration[7.0]
  def change
    add_column :cars, :car_category_id, :integer
  end
end
