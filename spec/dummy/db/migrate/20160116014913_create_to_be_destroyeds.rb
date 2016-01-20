class CreateToBeDestroyeds < ActiveRecord::Migration
  def change
    create_table :to_be_destroyeds do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
