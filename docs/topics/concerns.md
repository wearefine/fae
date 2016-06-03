# Fae Concerns

If you need to create custom classes, it's recommended you inherit from a Fae class and if you need to update a Fae class, look for a concern to inject into first.

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