class Types::ZigZagComponentType < Types::BaseObject

  graphql_name 'ZigZagComponent'

  field :id, ID, null: false
  field :name, String, null: true
  field :created_at, String, null: false
  field :updated_at, String, null: false
end
