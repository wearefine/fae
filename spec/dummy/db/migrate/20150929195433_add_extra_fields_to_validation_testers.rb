class AddExtraFieldsToValidationTesters < ActiveRecord::Migration
  def change
    add_column :validation_testers, :second_email, :string
    add_column :validation_testers, :unique_email, :string
    add_column :validation_testers, :second_url, :string
    add_column :validation_testers, :second_phone, :string
    add_column :validation_testers, :second_zip, :string
    add_column :validation_testers, :second_youtube_url, :string
  end
end
