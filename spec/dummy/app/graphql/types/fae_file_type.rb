class Types::FaeFileType < Types::BaseObject

  graphql_name 'FaeFile'
  description 'A Fae::File object'

  field :id, ID, null: false
  field :asset_url, String, null: true
  field :file_size, Integer, null: true
  field :created_at, String, null: false
  field :updated_at, String, null: false
end