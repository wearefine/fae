module Admin
  class PlayersController < Fae::BaseController

    before_action :set_parent_context

    def index
      @items = @klass.where(team_id: params[:team_id]).order(:first_name)
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
      @klass_humanized = "#{@parent_item.name} Player"
      @index_path = admin_team_players_path(@parent_item)
      @new_path = new_admin_team_player_path(@parent_item)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = @klass.where(team_id: params[:team_id]).find(params[:id])
    end

  end
end
