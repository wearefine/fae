class AddMfaEnablingUserToFaeOptions < ActiveRecord::Migration[7.0]
  def change
    add_column :fae_options, :mfa_enabling_user, :string
  end
end
