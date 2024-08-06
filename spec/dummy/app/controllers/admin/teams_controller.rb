module Admin
  class TeamsController < Fae::BaseController

    private

    def set_assoc_vars
      @coaches = Coach.all
      @players = Player.all
    end

    def use_pagination
      true
    end
  end
end
