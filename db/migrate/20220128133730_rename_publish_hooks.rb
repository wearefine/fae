class RenamePublishHooks < ActiveRecord::Migration[5.2]
  def change
    rename_table :fae_publish_hooks, :fae_deploy_hooks
  end
end
