# Devise::FailureApp controls how warden hands unauthentiacted requests
# there's a bug in Devise 3.4.1 in the scope_url private method
# the fix is on master, yet is unreleased
# chances are this can be removed after the next Devise release
# recall always shows the generic invalid credentials message
Devise::FailureApp.class_eval do
  def scope_url
    context = send(Devise.available_router_name)
    route = :"new_#{scope}_session_url"
    context.send(route, {})
  end

  def recall
    header_info = if relative_url_root?
      base_path = Pathname.new(relative_url_root)
      full_path = Pathname.new(attempted_path)

      { "SCRIPT_NAME" => relative_url_root,
        "PATH_INFO" => '/' + full_path.relative_path_from(base_path).to_s }
    else
      { "PATH_INFO" => attempted_path }
    end

    header_info.each do | var, value|
      if request.respond_to?(:set_header)
        request.set_header(var, value)
      else
        request.env[var]  = value
      end
    end

    flash.now[:alert] = I18n.t('devise.failure.invalid') if is_flashing_format?
    self.response = recall_app(warden_options[:recall]).call(request.env)
  end
end