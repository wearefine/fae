class AboutUsPage < Fae::StaticPage

  @slug = 'about_us'

  # required to set the has_one associations, Fae::StaticPage will build these associations dynamically
  def self.fae_fields
    {
      header: { type: Fae::TextField, validates: { presence: true } },
      introduction: { type: Fae::TextArea },
      body: {
        type: Fae::TextArea,
        languages: [:en, :zh],
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