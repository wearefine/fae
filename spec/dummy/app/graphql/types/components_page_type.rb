class Types::ComponentsPageType < Types::BaseObject

  graphql_name 'ComponentsPage'

  field :title, String, null: false
  field :name, String,
    null: true,
    method: :name_content
  field :flex_components, [Types::FlexComponentType], null: true, method: :active_flex_components
end
