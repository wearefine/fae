class Types::SingletonPageType < Types::BaseObject

  graphql_name 'SingletonPage'

  field :id, ID, null: false
  field :name, String, null: true
  field :slug, String, null: true
  field :image, Types::FaeImageType, null: true
  # field :cta, Types::FaeCtaType, null: true
  field :body, String, null: true
  field :created_at, String, null: false
  field :updated_at, String, null: false
end
