class PublishHooksAdjustments < ActiveRecord::Migration[5.2]
  def change
    add_column :fae_publish_hooks, :name, :string
    rename_column :fae_publish_hooks, :environment, :admin_environment
  end
end
