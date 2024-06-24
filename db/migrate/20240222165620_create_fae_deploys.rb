class CreateFaeDeploys < ActiveRecord::Migration[7.0]
  def change
    create_table :fae_deploys do |t|
      t.integer :user_id, index: true
      t.string :environment
      t.string :deploy_id, index: true
      t.string :deploy_status
      t.boolean :notified

      t.timestamps
    end
  end
end
