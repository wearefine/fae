class NestedTablesInFormPage < Fae::StaticPage

  @slug = 'nested_tables_in_form'

  # required to set the has_one associations, Fae::StaticPage will build these associations dynamically
  def self.fae_fields
    {
      list_header: { type: Fae::TextField },
      list_introduction: { type: Fae::TextArea },
      flex_header: { type: Fae::TextField },
      flex_introduction: { type: Fae::TextArea },
      seo_title: { type: Fae::TextField },
      seo_description: { type: Fae::TextField },
      social_media_title: { type: Fae::TextField },
      social_media_description: { type: Fae::TextArea },
      social_media_image: { type: Fae::Image }
    }
  end

end
