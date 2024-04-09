# This migration comes from fae (originally 20240220144206)
class AddReceiveDeployNotificationsToFaeUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :fae_users, :receive_deploy_notifications, :boolean, default: false
    add_index :fae_users, :receive_deploy_notifications
  end
end
