class Person < ActiveRecord::Base
  include Fae::BaseModelConcern

  def fae_display_field
    name
  end

  has_one :image, as: :imageable, class_name: '::Fae::Image', dependent: :destroy
  accepts_nested_attributes_for :image, allow_destroy: true

  validates_presence_of :name

  belongs_to :event, optional: true

  # Used by the filter form on the index page (a fae_filter_frame), which sends params as ?filter[search]=...
  def self.filter(params)
    scope = for_fae_index
    scope = scope.where('people.name LIKE ?', "%#{params['search']}%") if params['search'].present?
    scope = scope.where(event_id: params['event']) if params['event'].present?
    scope
  end
end
