class Types::FaeImageType < Types::BaseObject

  graphql_name 'FaeImage'
  description 'A Fae::Image object'

  field :id, ID, null: false
  field :asset_url, String, null: true
  field :asset_thumb_url, String, null: true
  field :caption, String, null: true
  field :alt, String, null: true
  field :file_size, Integer, null: true
  field :created_at, String, null: false
  field :updated_at, String, null: false

  # you can add custom methods to access Carrierwave versions
  def asset_thumb_url
    object.asset.thumb.url || object.asset_url if object.asset.present?
  end

end