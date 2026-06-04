module Types::BaseSeoFields
  include Types::BaseInterface

  field :derived_seo_title, String, null: true
  field :derived_seo_description, String, null: true
  field :derived_social_media_title, String, null: true
  field :derived_social_media_description, String, null: true
  field :derived_social_media_image, Types::FaeImageType, null: true

  # Base SEO Fields interface. Add this to any type that needs these fields. 
  # This also adds the ability to use a fragment for SEO fields on the FE
  # Add to any graphql type via:
  # implements Types::BaseSeoFields

end
