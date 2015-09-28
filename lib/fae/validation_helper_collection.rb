class ValidationHelperCollection

  def slug_regex
    /^[-a-zA-Z0-9]+$/
  end

  def email_regex
    /^\s*(([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})[\s\/,;]*)+$/i
  end

  def url_regex
    URI::regexp(%w(http https))
  end

  def phone_regex
    /\A(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$/
    # http://stackoverflow.com/questions/16699007/regular-expression-to-match-standard-10-digit-phone-number
  end

  def zip_regex
    /^(\d{5})?$/i
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
        message: 'no spaces or special characters',
        multiline: true
      }
    }
  end

  def email
    {
      format: {
        with: self.email_regex,
        message: 'is invalid',
        multiline: true
      }
    }
  end

  def unique_email
    {
      uniqueness: {
        message: 'That email address is already in use.'
      },
      format: {
        with: self.email_regex,
        multiline: true,
        message: 'is invalid'
      }
    }
  end

  def url
    {
      format: {
        with: self.url_regex,
        message: 'is invalid'
      }
    }
  end

  def phone
    {
      format: {
        with: self.phone_regex,
        multiline: true,
        message: 'is invalid'
      }
    }
  end

  def zip
    {
      format: {
        with: self.zip_regex,
        multiline: true,
        message: 'is invalid'
      }
    }
  end

  def youtube_url
    {
      format: {
        with: self.youtube_regex,
        message: 'is invalid'
      }
    }
  end

end