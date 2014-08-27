class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # needed to use Fae's form helpers, possibly move this to Fae through the controller inheritence?
  helper Fae::FormHelper
end
