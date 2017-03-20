# Fae Initializer

Fae's default config can be overwritten in a `config/initializers/fae.rb` file.

| key | type | default | description |
| --- | ---- | ------- | ----------- |
| has_top_nav | boolean | false | This determines if the main nav items are on the top or the side. |
| devise_secret_key | string | | unique Devise hash, generated on `rails g fae:install` |
| devise_mailer_sender | string | "change-me@example.com" | This email address will get passed to Devise and used as the from address in the password reset emails. |
| dashboard_exclusions | array | [] | The dashboard will show all objects with recent activity. |
| max_image_upload_size | integer | 2 | This will set a file size limit on image uploads in MBs. |
| max_file_upload_size | integer | 5 | This will set a file size limit on file uploads in MBs. |
| languages | hash | {} | This hash sets the supported languages for the multiple language toggle feature. |
| recreate_versions | boolean | false | Triggers `Fae::Image` to recreate Carrierwave versions after save. This is helpful when you have conditional versions that rely on attributes of `Fae::Image` by making sure they're saved before versions are created. |
| track_changes | boolean | true | This is the global toggle for the change tracker. |
| tracker_history_length | integer | 15 | This defines how many changes per object are kept in the DB. |
| disabled_environments | array | [] | This option will disable Fae complete when the app is running on one of the defined environments |
| per_page | integer | 25 | Sets the default number of items shown in paginated lists |
| use_cache | boolean | false | Determines whether or not Fae will utilize cache internally. See [docs](https://github.com/wearefine/fae/blob/master/docs/topics/caching.md) |
