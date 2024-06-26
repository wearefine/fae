class Types::TextComponentType < Types::BaseObject

  graphql_name 'TextComponent'

  field :id, ID, null: false
  field :name, String, null: true
  field :created_at, String, null: false
  field :updated_at, String, null: false
end
