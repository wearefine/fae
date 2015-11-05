class ValidationHelperCollection

  def slug_regex
    /\A[-_a-zA-Z0-9]+\z/
  end

  def email_regex
    /\A\s*(([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})[\s\/,;]*)+\z/
  end

  def url_regex
    URI::regexp(%w(http https))
  end

  def zip_regex
    /\A(\d{5})?\z/
  end

  def youtube_regex
    /[a-zA-Z0-9_-]{11}/
  end

  ### Complete Hash Validations

  def slug
    {
      uniqueness: true,
      presence: true,
      format: {
        with: self.slug_regex,
        message: 'cannot have spaces or special characters'
      }
    }
  end

  def email
    {
      allow_blank: true,
      format: {
        with: self.email_regex,
        message: 'is invalid'
      }
    }
  end

  def url
    {
      allow_blank: true,
      format: {
        with: self.url_regex,
        message: 'is invalid'
      }
    }
  end

  def zip
    {
      allow_blank: true,
      format: {
        with: self.zip_regex,
        message: 'is invalid'
      }
    }
  end

  def youtube_url
    {
      allow_blank: true,
      format: {
        with: self.youtube_regex,
        message: 'is invalid'
      }
    }
  end

end