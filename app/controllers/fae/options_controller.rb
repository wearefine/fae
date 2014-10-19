module Fae
  class OptionsController < ApplicationController

    def edit
      @option = Option.first
    end

    # PATCH/PUT /options/1
    def update
      if @option.update(option_params)
        render :edit, notice: 'Option was successfully updated.'
      else
        render :edit
      end
    end

    private

      # Only allow a trusted parameter "white list" through.
      def option_params
        params.require(:option).permit(:title, :time_zone, :colorway, :stage_url, :live_url, logo_attributes: [:id, :asset, :asset_cache, :attached_as, :alt], favicon_attributes: [:id, :asset, :asset_cache, :attached_as, :alt])
      end
  end
end
