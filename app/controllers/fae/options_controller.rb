module Fae
  class OptionsController < ApplicationController

    before_action :super_admin_only

    def edit
      @option = Option.first || Option.instance
      @option.build_logo if @option.logo.blank?
      @option.build_favicon if @option.favicon.blank?
    end

    # PATCH/PUT /options/1
    def update
      if @option.update(option_params)
        # add custom css and recompile assets to apply the custom highlight color if changed
        if option_params[:highlight_color].present?
          css_text = "$c-custom-highlight: #{option_params[:highlight_color]};"
          file = File.open('app/assets/stylesheets/highlight_color.scss', 'w') { |f| f << css_text; f.close }
          system 'rake assets:precompile RAILS_ENV=production'
          system 'touch tmp/restart.txt'
        end
        flash[:notice] = 'Option was successfully updated.'
        redirect_to :action => :edit
      else
        render :edit
      end
    end

    private

    # Only allow a trusted parameter "white list" through.
    def option_params
      params.require(:option).permit(:title, :highlight_color, :time_zone, :colorway, :stage_url, :live_url, logo_attributes: [:id, :asset, :asset_cache, :attached_as, :alt], favicon_attributes: [:id, :asset, :asset_cache, :attached_as, :alt])
    end
  end
end
