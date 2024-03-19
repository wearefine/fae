class AddMfaEnabeledToFaeOptions < ActiveRecord::Migration[7.0]
  def change
    add_column :fae_options, :site_mfa_enabled, :boolean, default: false
  end
end
