class Event < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  validates :city, inclusion: ["Los Angeles", "San Francisco", "Portland"];
  validates :name, presence: true

  belongs_to :release
  has_many :people
end