class Types::WidgetType < Types::BaseObject

  graphql_name 'Widget'

  field :id, ID, null: false
  field :name, String, null: true
  field :position, Integer, null: true
  field :on_stage, Boolean, null: true
  field :on_prod, Boolean, null: true
  field :created_at, String, null: false
  field :updated_at, String, null: false
end
