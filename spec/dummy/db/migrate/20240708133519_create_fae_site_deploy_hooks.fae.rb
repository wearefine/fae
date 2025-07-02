class CreateFaeSiteDeployHooks < ActiveRecord::Migration[7.0]
  def change
    create_table :fae_site_deploy_hooks do |t|
      t.string :environment
      t.string :url
      t.integer :position, index: true
      t.integer :site_id, index: true

      t.timestamps
    end
  end
end
