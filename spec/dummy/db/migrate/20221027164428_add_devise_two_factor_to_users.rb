class AddDeviseTwoFactorToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :fae_users, :otp_secret, :string
    add_column :fae_users, :consumed_timestep, :integer
    add_column :fae_users, :otp_required_for_login, :boolean
  end
end
