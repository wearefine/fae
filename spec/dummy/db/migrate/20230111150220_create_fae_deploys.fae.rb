# This migration comes from fae (originally 20230110160804)
class CreateFaeDeploys < ActiveRecord::Migration[7.0]
  def change
    create_table :fae_deploys do |t|
      t.integer :user_id, index: true
      t.string :user_name
      t.string :external_deploy_id, index: true

      t.timestamps
    end
  end
end
