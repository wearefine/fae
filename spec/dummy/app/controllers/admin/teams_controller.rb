module Admin
  class TeamsController < Fae::BaseController

    private

    def set_assoc_vars
      @coaches = Coach.all
      @players = Player.all
    end

    def set_item
      item = @klass.find(params[:id])
      @item = item.as_json.merge(coaches: item.coaches)
    end

    def use_pagination
      false
    end
  end
end
