class AddDraftToBeers < ActiveRecord::Migration[7.0]
  def change
    add_column :beers, :draft, :boolean, default: false
  end
end
