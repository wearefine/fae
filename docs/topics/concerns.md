# Fae Model and Controller Concerns

Each one of Fae's models and some controllers have a cooresponding concern. You can create that concern in your application to easily inject logic into built in classes, following Rails' concern pattern.

You have the option to override the class altogether, but the concern model will allow your app to inherit future features and bugfixes while customizing your behavior.

## Available Fae Concerns

| Fae Class                  | Concern Path |
|----------------------------|--------------|
| Fae::ApplicationController | app/controllers/concerns/application_controller_concern.rb |
| Fae::File                  | app/models/concerns/file_concern.rb |
| Fae::Image                 | app/models/concerns/image_concern.rb |
| Fae::Option                | app/models/concerns/option_concern.rb |
| Fae::StaticPage            | app/models/concerns/static_page_concern.rb |
| Fae::TextArea              | app/models/concerns/text_area_concern.rb |
| Fae::TextField             | app/models/concerns/text_field_concern.rb |
| Fae::User                  | app/models/concerns/user_concern.rb |

## Example: Adding OAuth2 logic to Fae::User

Say we wanted to add a lookup class method to `Fae::User` to allow for Google OAuth2 authentication. We simply need to add the following to our application:

`app/models/concerns/fae/user_concern.rb`
```ruby
module Fae
  module UserConcern
    extend ActiveSupport::Concern

    included do
      # overidde Fae::User devise settings
      devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :omniauthable, omniauth_providers: [:google_oauth2]
    end

    module ClassMethods
      # add new class method to Fae::User
      def self.find_for_google_oauth2(access_token, signed_in_resource = nil)
        data = access_token.info
        user = Fae::User.find_by_email(data['email'])

        unless user
          user = Fae::User.create(
            first_name: data['name'],
            email: data['email'],
            role_id: 3,
            active: 1,
            password: Devise.friendly_token[0, 20]
          )
        end
        user
      end
    end

  end
end
```
