class Types::FlexComponentType < Types::BaseObject

  graphql_name 'FlexComponent'

  field :id, ID, null: false
  field :instance, Types::FlexComponentUnionType, null: true, method: :component_instance

end