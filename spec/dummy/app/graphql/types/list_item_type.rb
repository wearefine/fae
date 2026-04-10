class Types::ListItemType < Types::BaseObject

  graphql_name 'ListItem'

  field :id, ID, null: false
  field :name, String, null: true
  field :people, String, null: true
  field :image, Types::FaeImageType, null: true
  field :on_stage, Boolean, null: true
  field :on_prod, Boolean, null: true
  field :position, Integer, null: true
  field :created_at, String, null: false
  field :updated_at, String, null: false
end
