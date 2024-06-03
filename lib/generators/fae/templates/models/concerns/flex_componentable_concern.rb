module FlexComponentableConcern
  extend ActiveSupport::Concern

  included do

    has_many :flex_components, as: :flex_componentable, dependent: :restrict_with_error
    has_many :active_flex_components, -> { active }, as: :flex_componentable, class_name: 'FlexComponent'

  end

end