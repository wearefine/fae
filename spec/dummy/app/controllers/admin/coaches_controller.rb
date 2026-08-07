module Admin
  class CoachesController < Fae::BaseController
    # Renders with Inertia + Vue and exercises deep side-nav hierarchy
    # (Teams > team > Personnel > Coaches).
    include Fae::InertiaRenderable

    before_action :set_parent_context

    def index
      render_fae_index(
        @klass.where(team_id: params[:team_id]).order(:first_name),
        columns: { first_name: 'First Name', last_name: 'Last Name' }
      )
    end

    def create
      @item = @klass.new(item_params)
      @item.team_id = params[:team_id]

      if @item.save
        redirect_to @index_path, notice: t('fae.save_notice')
      else
        render action: 'new', error: t('fae.save_error')
      end
    end

    private

    def set_parent_context
      @parent_item = Team.find(params[:team_id])
      @klass_humanized = "#{@parent_item.name} Coach"
      @index_path = admin_team_coaches_path(@parent_item)
      @new_path = new_admin_team_coach_path(@parent_item)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = @klass.where(team_id: params[:team_id]).find(params[:id])
    end

    def use_pagination
      true
    end

    def build_assets
      @item.build_image if @item.image.blank?
    end

  end
end
