class HomePage < Fae::StaticPage

  @slug = 'home'

  # required to set the has_one associations, Fae::StaticPage will build these associations dynamically
  def self.fae_fields
    {
      hero: Fae::TextField,
      introduction: Fae::TextArea,
      body: Fae::TextArea,
      hero_image: Fae::Image,
      welcome_pdf: Fae::File
    }
  end

end
