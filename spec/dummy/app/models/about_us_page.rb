class AboutUsPage < Fae::StaticPage

  @slug = 'about_us'

  fae_translate :introduction, :body
  # fae_image_translate :header_image

  # required to set the has_one associations, Fae::StaticPage will build these associations dynamically
  def self.fae_fields
    {
      header: { type: Fae::TextField, validates: { presence: true } },
      introduction: { type: Fae::TextArea, languages: Fae.languages.keys },
      body: {
        type: Fae::TextField,
        languages: Fae.languages.keys,
        validates: {
          length: {
            maximum: 150
          }
        }
      },
      header_image: { type: Fae::Image, languages: Fae.languages.keys }
    }
  end

end