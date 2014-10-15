class Event < ActiveRecord::Base
  include Fae::Concerns::Models::Base

    # t.string   "name"
    # t.date     "start_date"
    # t.date     "end_date"
    # t.string   "event_type"
    # t.string   "city"
    # t.integer  "person_id"
    # t.datetime "created_at"
    # t.datetime "updated_at"

  validates :city, inclusion: ["Los Angeles", "San Francisco", "Portland", "France"];

  belongs_to :release
  has_many :people
end