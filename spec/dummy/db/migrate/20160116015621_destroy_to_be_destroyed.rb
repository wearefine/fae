class DestroyToBeDestroyed < ActiveRecord::Migration
  def change
    drop_table :to_be_destroyeds
  end
end
