class Types::NestedTablesInFormPageType < Types::BaseObject

  graphql_name 'NestedTablesInFormPage'

  field :title, String, null: false
  field :list_header, String,
    null: true,
    method: :list_header_content
  field :list_introduction, String,
    null: true,
    method: :list_introduction_content
  field :flex_header, String,
    null: true,
    method: :flex_header_content
  field :flex_introduction, String,
    null: true,
    method: :flex_introduction_content
  field :seo_title, String,
    null: true,
    method: :seo_title_content
  field :seo_description, String,
    null: true,
    method: :seo_description_content
  field :social_media_title, String,
    null: true,
    method: :social_media_title_content
  field :social_media_description, String,
    null: true,
    method: :social_media_description_content
  field :social_media_image, Types::FaeImageType, null: true
end
