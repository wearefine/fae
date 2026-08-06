module Admin
  class KnobsController < Fae::FlexComponentBaseController

    def self.fae_form_fields
      [
        { name: :title, type: :text }
      ]
    end


  end
end