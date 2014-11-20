module Fae::AssetsValidatable
  extend ActiveSupport::Concern

  included do
    validate :asset_exists
  end

  def asset_exists
    errors.add(:asset, "#{self.class.to_s.gsub('Fae::','')} can't be empty") if required && asset.blank?
  end

end
