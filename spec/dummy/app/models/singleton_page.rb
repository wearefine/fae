class SingletonPage < ApplicationRecord
  include Fae::BaseModelConcern

  def self.instance
    first || new.tap { |item| item.save(validate: false) }
  end

  has_fae_cta :cta

  has_fae_image :image

  validates :name, presence: true
  validates :slug, presence: true

  def fae_display_field
    name
  end

end
