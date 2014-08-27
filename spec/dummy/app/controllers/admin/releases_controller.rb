class Admin::ReleasesController < ApplicationController
  before_action :set_admin_release, only: [:show, :edit, :update, :destroy]

  # GET /admin/releases
  def index
    @admin_releases = Admin::Release.all
  end

  # GET /admin/releases/1
  def show
  end

  # GET /admin/releases/new
  def new
    @admin_release = Admin::Release.new
  end

  # GET /admin/releases/1/edit
  def edit
  end

  # POST /admin/releases
  def create
    @admin_release = Admin::Release.new(admin_release_params)

    if @admin_release.save
      redirect_to @admin_release, notice: 'Release was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /admin/releases/1
  def update
    if @admin_release.update(admin_release_params)
      redirect_to @admin_release, notice: 'Release was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /admin/releases/1
  def destroy
    @admin_release.destroy
    redirect_to admin_releases_url, notice: 'Release was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_release
      @admin_release = Admin::Release.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def admin_release_params
      params.require(:admin_release).permit(:name, :slug, :intro, :body, :vintage, :price, :tasting_notes_pdf, :wine_id, :varietal_id, :on_stage, :on_prod, :position)
    end
end
