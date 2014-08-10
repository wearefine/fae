class RenameUsersToFaeUsers < ActiveRecord::Migration
  def change
    rename_table :users, :fae_users
  end
end
