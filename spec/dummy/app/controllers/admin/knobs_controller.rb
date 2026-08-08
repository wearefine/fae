module Admin
  class KnobsController < Fae::FlexComponentBaseController

    def self.fae_form_fields
      [
        {
          section: {
            title: 'Main',
            fields: [
              { name: :title, type: :text }
            ]
          }
        }
      ]
    end


  end
end