class Types::FaeVideoType < Types::BaseObject

  graphql_name 'FaeVideo'
  description 'A Fae::Video object, hosted on Mux'

  field :id, ID, null: false
  field :playback_id, String, null: true
  field :status, String, null: true
  field :ready, Boolean, null: false, method: :ready?
  field :title, String, null: true
  field :alt, String, null: true
  field :duration, Float, null: true
  field :aspect_ratio, String, null: true
  field :thumbnail_url, String, null: true
  field :created_at, String, null: false
  field :updated_at, String, null: false

end
