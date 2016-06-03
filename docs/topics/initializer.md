# Fae Initializer

Fae's default config can be overwritten in a `config/initializers/fae.rb` file.

| key | type | default | description |
| --- | ---- | ------- | ----------- |
| devise_secret_key | string | | unique Devise hash, generated on `rails g fae:install` |
| devise_mailer_sender | string | change-me@example.com | address used to send Devise notifications (i.e. forgot password emails) |
| dashboard_exclusions  | array | [] | array of models to hide in the dashboard |
| max_image_upload_size | integer | 2 | ceiling for image uploads in MB |
| max_file_upload_size | integer | 5 | ceiling for file uploads in MB |
| recreate_versions | boolean | false | Triggers `Fae::Image` to recreate Carrierwave versions after save. This is helpful when you have conditional versions that rely on attributes of `Fae::Image` by making sure they're saved before versions are created. |
| track_changes | boolean | true | Determines whether or not to track changes on your objects |
| tracker_history_length | integer | 15 | Determines the max number of changes logged per object |
| has_top_nav | boolean | false | Determines if the main nav items are on the top or the side |

### Example

```ruby
Fae.setup do |config|

  config.devise_secret_key = '79a3e96fecbdd893853495ff502cd387e22c9049fd30ff691115b8a0b074505be4edef6139e4be1a0a9ff407442224dbe99d94986e2abd64fd0aa01153f5be0d'

  # models to exclude from dashboard list
  config.dashboard_exclusions = %w( Varietal )

end
```