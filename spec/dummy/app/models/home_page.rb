class HomePage < Fae::StaticPage
  include Fae::Concerns::Models::Base

  @slug = 'home'

  # required to set the has_one associations, the static controller will build these associations dynamically
  def fae_fields
    {
      hero: Fae::TextField,
      introduction: Fae::TextArea,
      hero_image: Fae::Image,
      welocme_pdf: Fae::File
    }
  end

end