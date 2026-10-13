module Fae
  # Redirects after a non-GET request use 303 See Other so clients (browsers, Turbo, fetch)
  # follow them with a GET, even for PATCH and DELETE. An explicit `status:` still wins.
  #
  # This lives in a module because the method has to stay public (Devise's responder calls it
  # on the controller), and a public method defined directly on a controller becomes an action.
  module SeeOtherRedirects
    def redirect_to(options = {}, response_options = {})
      response_options = { status: :see_other }.merge(response_options) unless request.get? || request.head?
      super(options, response_options)
    end
  end
end
