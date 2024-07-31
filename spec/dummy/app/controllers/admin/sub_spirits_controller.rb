module Admin
  class SubSpiritsController < Fae::NestedBaseController



    private

    def build_assets
      @item.build_tout_cta if @item.tout_cta.blank?
    end

  end
end