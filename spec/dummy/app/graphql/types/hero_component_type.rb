class Types::HeroComponentType < Types::BaseObject

  graphql_name 'HeroComponent'

  field :id, ID, null: false
  field :title, String, null: true
  field :image, Types::FaeImageType, null: true
  field :created_at, String, null: false
  field :updated_at, String, null: false
end
