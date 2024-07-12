class PrivacyPage < Fae::StaticPage

  @slug = 'privacy'

  # required to set the has_one associations, Fae::StaticPage will build these associations dynamically
  def self.fae_fields
    {
      headline: { type: Fae::TextField,
        languages: Fae.languages.keys },
      body: { type: Fae::TextArea,
        languages: Fae.languages.keys },
      body_2: { type: Fae::TextArea,
        languages: Fae.languages.keys },

      seo_title: { type: Fae::TextField },
      seo_description: { type: Fae::TextArea },

      social_media_image: { type: Fae::Image },
      social_media_title: { type: Fae::TextField },
      social_media_description: { type: Fae::TextArea },
    }
  end

  fae_translate :headline, :body

  def failover_seo_title
    title
  end

end
