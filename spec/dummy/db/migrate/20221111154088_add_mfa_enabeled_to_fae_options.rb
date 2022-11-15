class AddMfaEnabeledToFaeOptions < ActiveRecord::Migration[7.0]
  def change
    add_column :fae_options, :mfa_enabled, :boolean, default: false
  end
end
