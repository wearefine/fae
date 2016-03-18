module Fae
  class ImagesController < ApplicationController

    #the initial crop view + handling of actual crop
    #
    #get 'images/:id/crop_image' => 'images#crop_image', as: :crop_image
    #patch 'images/:id/crop_image' => 'images#crop_image', as: :commit_crop
    def crop_image
      @image = Image.where(id: params[:id]).first
      @sizing_info = Image.sizing_info
      if image_params.present?
        if @image.update(image_params)
          #image model has a virtual attr: redirect. this will make redirects for submit and cancel
          #actions much easier to deal with especially for nested resources!
          #this is set automatically with request.path in image_uploader partial
          redirect_to(image_params[:redirect])
        end
      end
    end

    #ajax delete action
    #
    #post 'images/:id/delete_image' => 'images#delete_image', as: :delete_image
    #here we just remove the asset from the attached image model, because if we deleted
    #the model itself, re-uploading a new one would break.
    def delete_image
      image = Image.find_by_id(params[:id])
      image.remove_asset = true
      image.save
      CarrierWave.clean_cached_files!
      render :nothing => true
    end

  private

    #allow mass assignment
    def image_params
      if params[:image].present?
        params.require(:image).permit!
      else
        nil
      end
    end

  end
end