module Fae
  class Cta < ActiveRecord::Base
    include Fae::BaseModelConcern
    include Fae::CtaConcern

    # Rails' inflector does not attempt to pluralize 'cta' for the table name
    self.table_name = 'fae_ctas'

    belongs_to :ctaable, polymorphic: true, touch: true, optional: true

    def fae_display_field
      cta_label
    end

  end
end
