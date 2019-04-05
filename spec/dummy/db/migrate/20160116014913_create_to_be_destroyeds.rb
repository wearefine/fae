class CreateToBeDestroyeds < ActiveRecord::Migration[4.2]
  def change
    create_table :to_be_destroyeds do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
