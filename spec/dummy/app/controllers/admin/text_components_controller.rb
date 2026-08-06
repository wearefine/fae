module Admin
  class TextComponentsController < Fae::FlexComponentBaseController

    def self.fae_form_fields
      [
        { name: :name, type: :text },
        { name: :name_zh, type: :text },
        { name: :name_frca, type: :text }
      ]
    end

  end
end