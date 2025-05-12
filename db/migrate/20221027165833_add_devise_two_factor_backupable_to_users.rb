class AddDeviseTwoFactorBackupableToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :fae_users, :otp_backup_codes, :text, array: true
  end
end
