class Types::SubListItemType < Types::BaseObject

  graphql_name 'SubListItem'

  field :id, ID, null: false
  field :name, String, null: true
  field :body, String, null: true
  field :on_stage, Boolean, null: true
  field :on_prod, Boolean, null: true
  field :position, Integer, null: true
  field :list_item, Types::ListItemType, null: true
  field :created_at, String, null: false
  field :updated_at, String, null: false
end
