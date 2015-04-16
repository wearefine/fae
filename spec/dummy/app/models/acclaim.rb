class Acclaim < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  has_one :pdf,
          as: :fileable,
          class_name: '::Fae::File',
          dependent: :destroy
  accepts_nested_attributes_for :pdf, allow_destroy: true

  def fae_display_field
    publication
  end


  # def self.to_csv
  #   binding.pry
  #   CSV.generate do |csv|
  #     csv << column_names
  #     all.each do |item|
  #       csv << item.attributes.values_at(*column_names)
  #     end
  #   end
  # end

  belongs_to :release
end