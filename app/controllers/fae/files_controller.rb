module Fae
  class FilesController < ApplicationController
    # ajax delete action
    #
    # post 'files/:id/delete_file' => 'files#delete_file', as: :delete_file
    # here we just remove the asset from the attached file model, because if we deleted
    # the model itself, re-uploading a new one would break.
    def delete_file
      file = Fae::File.find_by_id(params[:id])
      file.remove_asset = true
      file.save
      render body: nil
    end

    private

    # allow mass assignment
    def file_params
      if params[:file].present?
        params.require(:file).permit!
      else
        nil
      end
    end
  end
end
