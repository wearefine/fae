module Fae
  class Page < ActiveRecord::Base
    has_many :text_areas,
             as: :contentable,
             class_name: 'Fae::TextArea',
             dependent: :destroy
    accepts_nested_attributes_for :text_areas, allow_destroy: true

    has_many :files,
             as: :fileable,
             class_name: 'Fae::File',
             dependent: :destroy
    accepts_nested_attributes_for :files, allow_destroy: true

    has_many :text_fields,
             as: :contentable,
             class_name: 'Fae::TextField',
             dependent: :destroy
    accepts_nested_attributes_for :text_field, allow_destroy: true
  end
end
