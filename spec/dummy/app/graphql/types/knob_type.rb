class Types::KnobType < Types::BaseObject

  graphql_name 'Knob'

  field :id, ID, null: false
  field :title, String, null: true
  field :created_at, String, null: false
  field :updated_at, String, null: false
end
