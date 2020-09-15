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
          filepath = 'app/assets/stylesheets/fae.scss'
          # opens the fae.scss file and substitues the new css string
          IO.write(filepath, File.open(filepath) do |f|
            f.read.gsub(/^.*c-custom-highlight.*/, css_text)
          end)
          # precompile assets so the css change is visible after updating
          system 'rake assets:precompile RAILS_ENV=production'
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
