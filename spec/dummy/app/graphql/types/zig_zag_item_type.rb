class Types::ZigZagItemType < Types::BaseObject

  graphql_name 'ZigZagItem'

  field :id, ID, null: false
  field :heading, String, null: true
  field :image, Types::FaeImageType, null: true
  field :body, String, null: true
  field :position, Integer, null: true
  field :on_stage, Boolean, null: true
  field :on_prod, Boolean, null: true
  field :zig_zag_component, Types::ZigZagComponentType, null: true
  field :created_at, String, null: false
  field :updated_at, String, null: false
end
