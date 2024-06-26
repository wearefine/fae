module FlexComponentableConcern
  extend ActiveSupport::Concern

  included do

    has_many :flex_components, as: :flex_componentable, dependent: :restrict_with_error, class_name: 'Fae::FlexComponent'
    # Example of how to scope the flex_components to only active ones given your installed flex_component.rb
    # defines an active scope.
    # has_many :active_flex_components, -> { active }, as: :flex_componentable, class_name: 'Fae::FlexComponent'

  end

end