class HomePage < Fae::StaticPage
  include Fae::Concerns::Models::Base

  @slug = 'home'

  # required to set the has_one associations, Fae::StaticPage will build these associations dynamically
  def fae_fields
    {
      hero: Fae::TextField,
      introduction: Fae::TextArea,
      body_copy_1: Fae::TextArea,
      body_copy_2: Fae::TextArea,
      body_copy_3: Fae::TextArea,
      body_copy_4: Fae::TextArea,
      body_copy_5: Fae::TextArea,
      body_copy_6: Fae::TextArea,
      body_copy_7: Fae::TextArea,
      body_copy_8: Fae::TextArea,
      body_copy_9: Fae::TextArea,
      body_copy_10: Fae::TextArea,
      hero_image: Fae::Image,
      welocme_pdf: Fae::File
    }
  end

end