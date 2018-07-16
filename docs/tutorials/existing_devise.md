# Configuring With Existing Devise Setup

* [Controllers](#controllers)
* [Views](#views)
* [Conclusion](#conclusion)

---

This tutorial was in reference to issue [wearefine/fae#302](https://github.com/wearefine/fae/issues/302). This will assist you in setting up Fae with existing [Devise](https://github.com/plataformatec/devise) or integrating with [Devise Token Auth](https://github.com/lynndylanhurley/devise_token_auth). This will continue using devise without losing functionality of Fae's devise configurations. This issue exists because Devise only allows one parent controller for the whole library. This solution is not to be taken as best practices but solves the issue with the hand that was dealt.

## Controllers

Fae provides a set of controller actions that setup the look and feel for the layout and other custom configurations. In order to keep these before actions from running on your devise controllers, you can setup a controller to skip them. If you look at the source code [here](https://github.com/wearefine/fae/blob/master/app/controllers/fae/application_controller.rb) you will see that fae sets devise base controller as `Fae::ApplicationController`. In order to keep these intact, you will have to create a controller that inherits that controller. Below is a snippet that will help you get started:

```ruby
class ApplicationDeviseController < Fae::ApplicationController
  
  skip_before_action :check_disabled_environment, if: -> { custom_devise_controller? }
  skip_before_action :first_user_redirect, if: -> { custom_devise_controller? }
  skip_before_action :authenticate_user!, if: -> { custom_devise_controller? }
  skip_before_action :build_nav, if: -> { custom_devise_controller? }
  skip_before_action :set_option, if: -> { custom_devise_controller?(['api']) }
  skip_before_action :detect_cancellation, if: -> { custom_devise_controller? }
  skip_before_action :set_change_user, if: -> { custom_devise_controller? }
  skip_before_action :set_locale, if: -> { custom_devise_controller? }

  protect_from_forgery prepend: true, if: Proc.new { |c| c.request.format.json? }
  
  helper_method :custom_devise_controller?

  def after_sign_in_path_for(_resource)
    custom_devise_controller?(['customers']) ? edit_customer_registration_path : super
  end

  def after_sign_out_path_for(_resource)
    custom_devise_controller?(['customers']) ? new_customer_session_path : super
  end

  private

  def custom_devise_controller?(values = ['api', 'customers'])
   values.include?(request.path[1..-1].split('/')[0])
  end
end

```

This snippet above will skip a set of given before actions on requests paths that you specify. For example you will see there is a resource route called `customers` and a namespace called `api` that both use devise controllers. You will notice on `:set_option`, there was an override for only `api` paths as I re-used fae's look and feel from devise for this project to same some time. That is up to you on how you want to handle that.

In order for the above controller to be used you will have to define the following in your `devise.rb` initializer:
```ruby
  config.parent_controller = 'ApplicationDeviseController'
```

Next you will have issues regarding the views interpretating resource paths.

## Views

So for example, in this project I had a devise model called customers. So I suggest copying all devise views from [here](https://github.com/wearefine/fae/tree/master/app/views/devise) if you plan on using Fae's look and feel. You will have to change all paths that are interprating resource name like the following example listed below:

`views/customers/confirmations/new.html.slim`
```slim
.login-form
  h2 style="margin-bottom: 20px" Resend confirmation instructions
  = simple_form_for(resource, :as => resource_name, :url => customer_confirmation_path, :html => { :method => :post }) do |f|
    = f.error_notification
    = f.full_error :confirmation_token

    .form-inputs
      = f.input :email, :required => true, :autofocus => true

    .form-actions
      = f.button :submit, "Resend confirmation instructions"
```

Notice that is `customer_confirmation_path` is now an explicit path name instead of `confirmation_path(resource_name)`. You will want to do this for the rest of the devise views and don't forget the mailer views as well.

In addition, if you want these views to be scoped you have to change the `devise.html.slim` layout to support that. 
```slim
.login-helper == render "#{custom_devise_controller? ? devise_mapping.scoped_path : 'devise'}/shared/links" unless params[:controller] == 'fae/setup' || params[:controller] == 'devise/registrations'
```

This will interpolate shared links to be `/customers/shared/links` instead of `/devise/shared/links`.

## Conclusion

If you want to use your own views instead of Fae's look and feel, you will have to override the layout on your own devise controllers which can be done with `layout 'my_custom_layout'`. Best of luck using Devise with Fae. 


