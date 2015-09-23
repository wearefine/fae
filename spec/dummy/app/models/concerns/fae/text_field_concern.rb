module Fae
  module TextFieldConcern
    extend ActiveSupport::Concern

    included do
      # validates :content, presence: true, if: :is_home_header?
    end

    # def is_home_header?
    #   contentable.slug == 'home' && attached_as == 'header'
    # end

    def instance_says_what
      'Fae::TextField instance: what?'
    end

    module ClassMethods
      def class_says_what
        'Fae::TextField class: what?'
      end
    end

  end
end