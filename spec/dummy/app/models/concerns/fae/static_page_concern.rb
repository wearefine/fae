module Fae
  module StaticPageConcern
    extend ActiveSupport::Concern

    included do

      has_many :flex_components, as: :flex_componentable, dependent: :restrict_with_error, class_name: 'Fae::FlexComponent'
      has_many :active_flex_components, -> { active }, as: :flex_componentable, class_name: 'Fae::FlexComponent'

      has_many :list_items

      has_many :static_page_aromas
      has_many :aromas, through: :static_page_aromas
      has_many :active_aromas, -> { active }, through: :static_page_aromas, source: :aroma

    end

    def instance_says_what
      'Fae::StaticPage instance: what?'
    end

    module ClassMethods
      def class_says_what
        'Fae::StaticPage class: what?'
      end
    end

  end
end