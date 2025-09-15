class AddMfaEnabeledToFaeUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :fae_users, :user_mfa_enabled, :boolean
  end
end
