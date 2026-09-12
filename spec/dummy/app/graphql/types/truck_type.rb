class Types::TruckType < Types::BaseObject

  graphql_name 'Truck'

  field :id, ID, null: false
  field :name, String, null: true
  field :slug, String, null: true
  field :image, Types::FaeImageType, null: true
  field :created_at, String, null: false
  field :updated_at, String, null: false
end
