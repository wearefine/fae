class HomePage < Fae::StaticPage

  @slug = 'home'

  # required to set the has_one associations, Fae::StaticPage will build these associations dynamically
  def self.fae_fields
    {
      header: {
        type: Fae::TextField,
        languages: Fae.languages.keys
      },
      hero: Fae::TextField,
      email: {
        type: Fae::TextField,
        validates: {
          format: {
            with: /\A[^@]+@[^@]+\z/,
            message: 'should look like an email address, right?'
            },
          allow_blank: true
          }
        },
      phone: { type: Fae::TextField },
      cell_phone: { type: Fae::TextField },
      work_phone: { type: Fae::TextField },
      introduction: {
        type: Fae::TextArea,
        validates: {
          length: { maximum: 100 }
          },
          languages: Fae.languages.keys
        },
      introduction_2: {
        type: Fae::TextArea,
        validates: {
          length: { maximum: 100 }
          },
          languages: Fae.languages.keys
        },
      body: Fae::TextArea,
      hero_image: Fae::Image,
      welcome_pdf: Fae::File
    }
  end

end
