class ComponentsPage < Fae::StaticPage

  @slug = 'components'

  # required to set the has_one associations, Fae::StaticPage will build these associations dynamically
  def self.fae_fields
    {
      name: { type: Fae::TextField }
    }
  end

end
