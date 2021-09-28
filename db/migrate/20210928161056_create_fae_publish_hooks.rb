class CreateFaePublishHooks < ActiveRecord::Migration[5.2]
  def change
    create_table :fae_publish_hooks do |t|
      t.string :url
      t.string :environment, index: true
      t.datetime :last_published_at, index: true

      t.timestamps
    end
  end
end
