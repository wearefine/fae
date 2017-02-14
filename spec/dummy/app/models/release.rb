class Release < ActiveRecord::Base
  include Fae::BaseModelConcern

  def fae_display_field
    name
  end

  validates :name, presence: true, length: {in: 3..15}, uniqueness: true, exclusion: %w(admin danny)
  validates :body, length: { maximum: 900 }
  validates :description, length: { maximum: 500 }
  validates :price, numericality: {greater_than: 12}, allow_blank: true
  validates :video_url, format: /[a-zA-Z0-9_-]{11}/, allow_blank: true
  validates :wine_id, presence: true
  validates :intro, length: { maximum: 100 }
  validates :release_date, presence: true

  belongs_to :wine
  belongs_to :varietal

  has_many :acclaims
  has_many :aromas
  has_many :release_notes

  has_many :release_selling_points
  has_many :selling_points, through: :release_selling_points
  accepts_nested_attributes_for :release_selling_points

  has_many :event_releases
  has_many :events, through: :event_releases

  has_fae_image :bottle_shot

  has_fae_image :hero_image

  has_one :label_pdf, as: :fileable, class_name: '::Fae::File', dependent: :destroy
  accepts_nested_attributes_for :label_pdf, allow_destroy: true

  def self.filter(params)
    conditions = {}
    conditions[:wine_id] = params['wine'] if params['wine'].present?
    conditions['acclaims.id'] = params['acclaims'] if params['acclaims'].present?

    search = {}
    if params['search'].present?
      search = ["releases.name LIKE ? OR wines.name_en like ?", "%#{params['search']}%", "%#{params['search']}%"]
    end

    for_fae_index
      .includes(:wine, :acclaims).references(:wine, :acclaims)
      .where(conditions).where(search)
  end

  def fae_tracker_blacklist
    [:position, 'price']
  end

end
