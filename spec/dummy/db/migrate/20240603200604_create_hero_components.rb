class CreateHeroComponents < ActiveRecord::Migration[7.0]
  def change
    create_table :hero_components do |t|
      t.string :title

      t.timestamps
    end
  end
end
