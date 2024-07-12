class GlobalContentPage < Fae::StaticPage

  @slug = 'global_content'

  # required to set the has_one associations, Fae::StaticPage will build these associations dynamically
  def self.fae_fields
    {
      website_name: { type: Fae::TextField },
      default_seo_title: { type: Fae::TextField },
      social_media_title: { type: Fae::TextField },
      social_media_description: { type: Fae::TextArea },
      analytics_tag_manager: { type: Fae::TextField },
      copyright_text: { type: Fae::TextField },
      twitter_profile_link: { type: Fae::TextField },
      linkedin_profile_link: { type: Fae::TextField },
      company_motto: { type: Fae::TextArea , languages: [:en, :zh, :frca]},
    }
  end

end
