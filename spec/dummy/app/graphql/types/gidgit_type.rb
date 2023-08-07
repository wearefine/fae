class Types::GidgitType < Types::BaseObject

  graphql_name 'Gidgit'

  field :id, ID, null: false
  field :name, String, null: true
  field :created_at, String, null: false
  field :updated_at, String, null: false
end
