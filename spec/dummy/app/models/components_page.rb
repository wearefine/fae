class ComponentsPage < Fae::StaticPage

  @slug = 'components'

  # required to set the has_one associations, Fae::StaticPage will build these associations dynamically
  def self.fae_fields
    {
      name: { type: Fae::TextField },
      seo_title: { type: Fae::TextField },
      seo_description: { type: Fae::TextArea },
      social_media_image: { type: Fae::Image },
      social_media_title: { type: Fae::TextField },
      social_media_description: { type: Fae::TextArea },
    }
  end

end
