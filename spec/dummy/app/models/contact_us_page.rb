class ContactUsPage < Fae::StaticPage

  @slug = 'contact_us'

  # required to set the has_one associations, Fae::StaticPage will build these associations dynamically
  def self.fae_fields
    {
      hero: { type: Fae::Image, languages: Fae.languages.keys },
      email: { type: Fae::TextField },
      body: {
        type: Fae::TextArea,
        languages: [:en, :zh],
        validates: {
          length: {
            maximum: 150
          }
        }
      }
    }
  end

end
