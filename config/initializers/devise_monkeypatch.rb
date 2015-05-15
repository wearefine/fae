# Devise::FailureApp controls how warden hands unauthentiacted requests
# there's a bug in Devise 3.4.1 in this private method
# the fix is on master, yet is unreleased
# chances are this can be removed after the next Devise release
Devise::FailureApp.class_eval do
  def scope_url
    context = send(Devise.available_router_name)
    route = :"new_#{scope}_session_url"
    context.send(route, {})
  end
end