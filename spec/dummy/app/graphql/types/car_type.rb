class Types::CarType < Types::BaseObject

  graphql_name 'Car'

  field :id, ID, null: false
  field :name_en, String, null: true
  field :name_frca, String, null: true
  field :name_zh, String, null: true
  field :image_en, Types::FaeImageType, null: true
  field :image_frca, Types::FaeImageType, null: true
  field :image_zh, Types::FaeImageType, null: true
  field :created_at, String, null: false
  field :updated_at, String, null: false
end
