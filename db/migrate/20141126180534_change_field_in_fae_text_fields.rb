class ChangeFieldInFaeTextFields < ActiveRecord::Migration
  def change
    rename_column :fae_text_fields, :attatched_as, :attached_as
  end
end
