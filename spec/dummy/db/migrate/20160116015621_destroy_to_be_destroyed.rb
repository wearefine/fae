class DestroyToBeDestroyed < ActiveRecord::Migration[4.2]
  def change
    drop_table :to_be_destroyeds
  end
end
