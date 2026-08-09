class Types::IntroPageType < Types::BaseObject

  graphql_name 'IntroPage'

  field :id, ID, null: false
  field :title, String, null: true
  field :body, String, null: true
  field :date, String, null: true
  field :image, Types::FaeImageType, null: true
  field :pdf, Types::FaeFileType, null: true
  field :created_at, String, null: false
  field :updated_at, String, null: false
end
