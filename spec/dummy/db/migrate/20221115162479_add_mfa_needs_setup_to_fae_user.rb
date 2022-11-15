class AddMfaNeedsSetupToFaeUser < ActiveRecord::Migration[7.0]
  def change
    add_column :fae_users, :mfa_needs_setup, :boolean
  end
end
