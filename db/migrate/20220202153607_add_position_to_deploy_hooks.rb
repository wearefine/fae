class AddPositionToDeployHooks < ActiveRecord::Migration[5.2]
  def change
    add_column :fae_deploy_hooks, :position, :integer
    add_index :fae_deploy_hooks, :position
  end
end
