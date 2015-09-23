class HomePage < Fae::StaticPage

  @slug = 'home'

  # required to set the has_one associations, Fae::StaticPage will build these associations dynamically
  def self.fae_fields
    {
      header: {
        type: Fae::TextField,
        validates: { presence: true }
        },
      hero: {
        type: Fae::TextField,
        validates: { length: { maximum: 3 }}
        },
      introduction: Fae::TextArea,
      body: Fae::TextArea,
      hero_image: Fae::Image,
      welcome_pdf: Fae::File
    }
  end

end
