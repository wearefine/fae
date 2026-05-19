class <%= join_model_class_name %> < ApplicationRecord

  belongs_to :<%= owner_association_name %>, touch: true<%= owner_belongs_to_class_name_option %>
  belongs_to :<%= joined_association_name %><%= joined_belongs_to_class_name_option %>

  acts_as_list add_new_at: :top, scope: :<%= owner_association_name %>
  default_scope { order(:position) }

  def fae_display_field
    <%= joined_association_name %>&.fae_display_field
  end

end