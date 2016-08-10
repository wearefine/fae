class Admin::EventsController < Fae::BaseController

  before_action do
    set_class_variables "special event"
  end

  private

  def use_pagination
    true
  end
end
