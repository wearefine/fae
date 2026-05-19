class <%= join_model_class_name %> < ApplicationRecord

  acts_as_list add_new_at: :top, scope: :<%= owner_association_name %>
  default_scope { order(:position) }

  belongs_to :<%= owner_association_name %>, touch: true
  belongs_to :<%= joined_association_name %>

  def fae_display_field
    <%= joined_association_name %>&.fae_display_field
  end

end