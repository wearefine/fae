# Fae Installation and Usage

[TOC]

---

# Installation

Add the gem to your Gemfile and run `bundle install`

```ruby
gem 'fae-rails', git: 'git@bitbucket.org:wearefine/fae.git'
```
Run the installer

```bash
$ rails g fae:install
```

After the installer completes, visit `/admin` and setup your first user account. That should automatically log you in to your blank Fae instance.

## Dependencies

### Rails

Fae supports Rails >= 4.1.

### Sass and sass-rails

Fae requires `sass >= 3.4` and `sass-rails >= 5`.

If you're using Rails 4.1 you'll need to update the versions in the `Gemfile`:

```ruby
gem 'sass-rails', '~> 5.0.0'
gem 'sass', '~> 3.4.0'
```

and run:

```bash
$ bundle update sass-rails
$ bundle update sass
```

## fae:install

Fae's installer will do the following:

- add Fae's namespace and route to `config/routes.rb`
- add `app/assets/stylesheets/fae.scss` for UI color management and custom CSS
- add `app/assets/javascripts/fae.js` for custom JS
- add `app/controllers/concerns/fae/nav_items.rb` to manage main navigation
- add Fae's initializer: `config/initializers/fae.rb`
- add `config/initializers/judge.rb` for validation config
- copies over migrations from Fae
- runs `rake db:migrate`
- seeds the DB with Fae defaults

## DB Seed

Fae comes with a rake task to seed the DB with defaults:

```bash
rake fae:seed_db RAILS_ENV=<your_env>
```

If you ran the installer, the task will be run automatically. But if you are setting up an established Fae instance locally or deploying to a server, running this will get you setup with some defaults.

## Version management

Fae follows semantic versioning, so you can expect the following format: `major.minor.patch`. Patch versions add bugfixes, minor versions add backwards compilable features and major versions add non-backward compatible features.

Until Fae is publically released we'll maintain branches for each major release and tag each patch. You can add arguments to the gem claration to help lock in a version if you are running `bundle update`:

```ruby
gem 'fae-rails', git: 'git@bitbucket.org:wearefine/fae.git', branch: 'v1'
gem 'fae-rails', git: 'git@bitbucket.org:wearefine/fae.git', tag: 'v1.0.3'
```

---

# Fae Initializer

Fae's default config can be overwritten in a `config/initializers/fae.rb` file.

| key | type | default | description
|-|-|-|-|
| devise_secret_key | string | | unique Devise hash
| devise_mailer_sender | string | change-me@example.com | address used to send Devise notifications (i.e. forgot password emails)
| dashboard_exclusions  | array | [] | array of models to hide in the dashboard
| max_image_upload_size | integer | 2 | ceiling for image uploads in MB
| max_file_upload_size | integer | 5 | ceiling for file uploads in MB
| recreate_versions | boolean | false | Triggers `Fae::Image` to recreate Carrierwave versions after save. This is helpful when you have conditional versions that rely on attributes of `Fae::Image` by making sure they're saved before versions are created.
| track_changes | boolean | true | Determines whether or not to track changes on your objects
| tracker_history_length | integer | 15 | Determines the max number of changes logged per object

### Example

```ruby
Fae.setup do |config|

  config.devise_secret_key = '79a3e96fecbdd893853495ff502cd387e22c9049fd30ff691115b8a0b074505be4edef6139e4be1a0a9ff407442224dbe99d94986e2abd64fd0aa01153f5be0d'

  # models to exclude from dashboard list
  config.dashboard_exclusions = %w( Varietal )

end
```

---

# Devise Action Mailer Configuration

In order for Fae's password reset email function to work you need to make sure you application can send mail and set a default url option for ActionMailer in each `config/environments/*env.rb` file.

## Example

```ruby
Rails.application.configure do
  # development.rb
  config.action_mailer.default_url_options = { host: 'localhost:3000' }
  # remote_development.rb
  config.action_mailer.default_url_options = { host: 'dev.yoursite.afinesite.com' }
  # stage.rb
  config.action_mailer.default_url_options = { host: 'stage.yoursite.afinesite.com' }
  # production.rb
  config.action_mailer.default_url_options = { host: 'yoursite.afinesite.com' }
  # production.rb
  config.action_mailer.default_url_options = { host: 'yoursite.com' }
end
```

Be sure to update this each time your domain or subdomain changes (i.e. when you launch the website and the project drops .afinesite and .afinedevelopment)

---

# Generators

Once you have Fae installed, you're ready to start generating your data model. Fae comes with a few generators that work similarly to the ones in Rails. The idea is scaffolding a model with these generators will give you a section to create, edit and delete objects.

## fae:scaffold

```ruby
rails g fae:scaffold [ModelName] [field:type] [field:type]
```
| option | description |
|-|-|
| ModelName | singular camel-cased model name |
| field | the attributes column name |
| type | the column type (defaults to `string`), find all options in [Rails' documentaion](http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/TableDefinition.html#method-i-column) |

This is Fae's main generator. It will create the following:

- model
- controller and views for fully CRUDable section
- migration
- resource routes
- link in `app/controllers/concerns/fae/nav_items.rb`

### Special Attributes

**name**/**title** will automatically be set as the model's `fae_display_field`.

**position** will automatically make the section's index table sortable, be ignored from the form and add acts_as_list and default_scope to the model.

**on_prod**/**on_stage**/**active** will automatically be flag fields in the section's index and ignored in the form.

**_id**/**:references** will automatically be setup as an association in the form.

### Example

```bash
rails g fae:scaffold Person first_name last_name title body:text date_of_birth:date position:integer on_stage:boolean on_prod:boolean group:references
```


## fae:nested_scaffold

```bash
rails g fae:nested_scaffold [ModelName] [field:type] [field:type] [--parent-model=ParentModel]
```

| option | description |
|-|-|
| `[--parent-model=ParentModel]` | an optional flag that adds the association to the generated model.|

The nested scaffold creates a model that will be nested in another object's form via the `nested_table_advanced` partial. This generator is very similar to `fae:scaffold`, the main difference is in the views that are setup to serve the nested form.


## fae:nested_index_scaffold

```bash
rails g fae:nested_index_scaffold [ModelName] [field:type] [field:type]
```

The nested index scaffold creates a normal model and a controller that supports the nested_index_form partial. This generator is very similar to `fae:scaffold`, the main difference is in the views that are setup to serve the nested form.

## fae:page

```bash
rails g fae:page [PageName] [field:type] [field:type]
```

| option 	| description |
|-----------|-------------|
| PageName	| the name of the page |
| field 	| the name of the content block |
| type 		| the type of the content block (see table below) |

| content block | associated object |
|---------------|-------------------|
| string 		| Fae::TextField |
| text 			| Fae::TextArea |
| image			| Fae::Image |
| file			| Fae::File |

The page generator scaffolds a page into Fae's content blocks system. More on that later, for now here's what it does:

- creates or adds to `app/controllers/admin/content_blocks_controller.rb`
- creates a `#{page_name}_page.rb` model
- creates a form view in `app/views/admin/content_blocks/#{page_name}.html.slim`

### Example

```bash
rails g fae:page AboutUs title:string introduction:text body:text header_image:image
```

---

# Models

A generated model will start off with sensible defaults based on the attributes you used in the generator. Here are some common custom additions you should be aware of.

## Fae's Base Model Concern

To allow Fae to push out any model specific updates to your application models, include the concern at the top of the class body:

```ruby
class Release < ActiveRecord::Base
  include Fae::BaseModelConcern
  # ...
end
```

## fae_display_field

Fae uses `fae_display_field` in a our table views. Defining it as a class method that returns the value of one or multiple attributes is required for those tables to display properly.

If the model is generated, then it will use `name` or `title` by default.

### Examples

```ruby
def fae_display_field
  title
end
```

```ruby
def fae_display_field
  "#{last_name}, #{first_name}"
end
```

## for_fae_index

Fae uses a class method called `for_fae_index` as a scope for index views and associated content in form elements. This method is inherited from `Fae::BaseModelConcern`.

By default, this method uses position, name, or title attributes. If it can't find any of those it will raise the following exception:

```
No order_method found, please define for_fae_index as a #{model_name} class method to set a custom scope.
```

To override the default or get rid of this exception, simple define the class method in your model:

```ruby
def self.for_fae_index
  order(:first_name)
end
```

## to_csv

Fae uses a class method called `to_csv` as a method to export all the objects related to a given model to a csv. This method is inherited from `Fae::BaseModelConcern`. It is meant to be called from the index action.


## Nested Resources

If you use nested resource routes and want updates on those objects to show up in the dashboard, you'll need to define it's parent for Fae to know how to link them.

To do this, add a class method called `fae_parent` pointing to the underscored association to the parent object. Here is an example:

routes.rb
```ruby
namespace :admin do
  resources :groups do
    resources :people
  end
end
```

models/person.rb
```ruby
# if this is the parent
belongs_to :group

# then you'll define this
def fae_parent
  group
end
```

## Validation

Fae doesn't deal with any validation definitions in your application models, you'll have to add those. However, there are some pre-defined regex validation helpers to use in your models. See examples below.

### Validation Helpers

Fae validation helpers come in two flavors; regex only, and complete hash.

Regex:

| option        | description                                             |
|---------------|---------------------------------------------------------|
| slug_regex    | no spaces or special characters                         |
| email_regex   | valid email with @ and .                                |
| url_regex     | http and https urls                                     |
| zip_regex     | 5 digit zip code                                        |
| youtube_regex | matches youtube id, i.e. the 11 digits after "watch?v=" |

example:

```ruby
validates :slug,
  uniqueness: true,
  presence: true,
  format: {
    with: Fae.validation_helpers.slug_regex,
    message: 'no spaces or special characters'
  }
```

Complete:

| option       | description                                      |
|--------------|--------------------------------------------------|
| slug         | uniqueness, presence, regex format with message  |
| email        | regex format with message, allow blank           |
| url          | regex form with message, allow blank             |
| zip          | regex format with message, allow blank           |
| youtube_url  | regex format with message, allow blank           |

example:

```ruby
validates :slug, Fae.validation_helpers.slug
```

### Judge and Uniqueness

Fae uses [Judge](https://github.com/joecorcoran/judge) to automatically add client side validation from the declarations in the models. The caveat is Judge requires you to expose any attributes that have a uniqueness validation. You can do this in `config/initializers/jugde.rb`:

```ruby
Judge.configure do
  expose Person, :slug
  expose Wine, :name, :slug
end
```

## Image and File Associations

Fae provides models for images and files: `Fae::Image` and `Fae::File` respectively. These models come with their own attributes, validations and uploaders and can be polymorphically associated to your application models.

Here's a basic example:

```ruby
has_one :bottle_shot, -> { where(attached_as: 'bottle_shot') },
  as: :imageable,
  class_name: '::Fae::Image',
  dependent: :destroy
accepts_nested_attributes_for :bottle_shot, allow_destroy: true
```

Here's the breakdown:

`has_one :bottle_shot` sets the name of the custom association.

`-> { where(attached_as: 'bottle_shot') }` sets the scope of the association. If we have more than one `Fae::Image` we need to set the `attached_as` to distinguish it from other images associated to that model.

`as: :imageable, class_name: '::Fae::Image'` defines the polymorphic association.

`dependent: :destroy` will make sure the image object is destroyed along with the parent object.

`accepts_nested_attributes_for :bottle_shot, allow_destroy: true` allows the image/file uploader to be nested in the parent object's form in Fae.

### Other Examples

An onject with many gallery images:

```ruby
has_many :gallery_images, -> { where(attached_as: 'gallery_images') },
  as: :imageable,
  class_name: '::Fae::Image',
  dependent: :destroy
accepts_nested_attributes_for :gallery_images, allow_destroy: true
```

A file example:

```ruby
has_one :tasting_notes_pdf, -> { where(attached_as: 'tasting_notes_pdf') },
  as: :fileable,
  class_name: '::Fae::File',
  dependent: :destroy
accepts_nested_attributes_for :tasting_notes_pdf, allow_destroy: true
```

If the object only has one image association, you can get away with omitting the scope:

```ruby
has_one :image, as: :imageable, class_name: '::Fae::Image', dependent: :destroy
accepts_nested_attributes_for :image, allow_destroy: true
```

---

# Controllers

Controllers that manage models in Fae should be namespaced and inherit from `Fae::BaseController`. Controllers that are generated have this already in place:

```ruby
module Admin
  class PeopleController < Fae::BaseController
    # ...
  end
end
```

For a standard Fae section you can pretty much leave your controller empty. Most of the magic happens in [Fae::BaseController](https://bitbucket.org/wearefine/fae/src/master/app/controllers/fae/base_controller.rb). But there are a few things you should know about.

## Building Assets

If the section manages objects with associated images or files, you'll need to build those objects by overriding the `build_assets` private method.

```ruby
module Admin
  class WinesController < Fae::BaseController

    private

    def build_assets
      @item.build_bottle_shot if @item.bottle_shot.blank?
      @item.build_label_pdf if @item.label_pdf.blank?
    end
  end
end
```

## Custom Titles in Views

If you'd like to change the generated titles in the Fae views, you can do so with the following `before_action`.

```ruby
module Admin
  class WinesController < Fae::BaseController
    before_action do
      set_class_variables 'Vinos'
    end
  end
end
```

This will affect the add button text and index/form page titles.

---

# Navigation Items

When you use the generators, a link to the section appears in the main navigation of the admin. This is done by automatically adding to `app/controllers/concerns/fae/nav_items.rb`. However, this file is available for you to customize the nav however you'd like.

The navigation is built of of the array set in the `nav_items` method. Each array item is a hash with these available keys:

| Key | Type | Description |
|-|-|
| text | string | the link's text |
| path | string or named route | the link's href (defaults to '#') |
| class | string | an added class to the link |
| sublinks | array of hashes | nested links to be displayed in a dropdown |

## Named Routes in nav_items.rb

Since the `nav_items` concern hooks directly into Fae, named routes need context using the following prefixes:

```ruby
def nav_items
  [
    # use `main_app.` for application routes (even in your admin)
    { text: 'Cities', path: main_app.admin_cities_path },
    # use `fae.` for Fae routes
    { text: 'Pages', path: fae.pages_path }
  ]
end
```

## Sublinks

When sublinks are present, the main nav item will trigger a drawer holding the sublinks to open/close. Add sublinks using the following format:

```ruby
def nav_items
  [
    {
      text: 'Items with sublinks', sublinks: [
        { text: 'Item Sublink 1', path: main_app.admin_some_path },
        { text: 'Item Sublink 2', path: main_app.admin_someother_path }
      ]
    }
  ]
end
```

## Dynamic Content in Nav

Dynamic content is allowed in the the `nav_items` concern. Here's an example:

```ruby
module Fae
  module NavItems
    extend ActiveSupport::Concern

    def nav_items
      [
        { text: 'Releases', path: main_app.admin_releases_path },
        { text: 'Tiers', sublinks: tier_sublinks }
      ]
    end

    private

    def tier_sublinks
      tiers_arr = [{ text: 'New Tier', path: main_app.new_admin_tier_path }]
      Tier.each do |tier|
        tiers_arr << { text: tier.name, path: main_app.edit_admin_tier_path(tier) }
      end
      tiers_arr
    end

  end
end
```

---

# Form Helpers
[Click here for full documentation on Fae's form helpers](https://bitbucket.org/wearefine/fae/src/master/docs/helpers.md#markdown-header-form-helpers)

Generated forms start you off on a good place to manage the object's content, but chances are you'll want to customize them and add more fields as you data model evolves. Fae provides a number of form helpers to help you leverage Fae's built in features will allowing customization when needed.

Form helpers in Fae use the [simple_form](https://github.com/plataformatec/simple_form) gem as it's base. In most cases options that simple_form accepts can be passed into these helpers directly. The reason why we've established these helpers it to allow for customized options. They also provide a method to directly hook into Fae, so we can push out features and bugfixes.

---

# View Helpers and Partials

Fae also provides a number of other built in view helpers and partials, that are documented in [helpers.md](https://bitbucket.org/wearefine/fae/src/master/docs/helpers.md).

[Click here for view helpers](https://bitbucket.org/wearefine/fae/src/master/docs/helpers.md#markdown-header-view-helpers)
[Click here for Fae partials](https://bitbucket.org/wearefine/fae/src/master/docs/helpers.md#markdown-header-fae-partials)

---

# Custom Helpers

If you want to add your own helper methods for your Fae views, simply create and add them to `app/helpers/fae/fae_helper.rb`.

```ruby
module Fae
  module FaeHelper
    # ...
  end
end
```

---

# Cloning

[Click here for full documentation on Fae's cloning](https://bitbucket.org/wearefine/fae/src/master/docs/cloning.md)

Many users find it easier to clone records that have similar content, rather than spending the time manually setting them up. Fae has the ability to allow one-click clones from the index or the edit form, as well as flexibility to whitelist attributes and clone assocations.

---

# Pages and Content Blocks

Fae has a built in system to handle content blocks that are statically wired to pages in your site. This is for content that isn't tied to an object in your data model, e.g. home, about and terms content.

The system is just your basic inherited singleton with dynamic polymorphic associations. Kidding aside, the complexity of the system is hidden and "it just works™" if you use the generators and/or follow the conventions. This allows for dynamic content blocks that can be added without database migrations and wired up without static IDs!

## Pages vs Content Blocks

**Pages** are groups of **content blocks** based on the actual pages they appear on the site. For the following example, we will use a page called `AboutUs`, which will have content blocks for `hero_image`, `title`, `introduction`, `body` and `annual_report`.

## Generating Pages

It is highly recommended you use the built in generator to add pages, especially if it's the first page in the admin. Let's do that for our example:

```bash
rails g fae:page AboutUs hero_image:image hero_text:string introduction:text body:text annual_report:file
```

This will generate...

`app/models/about_us_page.rb`
```ruby
class AboutUsPage < Fae::StaticPage

  @slug = 'about_us'

  # required to set the has_one associations, Fae::StaticPage will build these associations dynamically
  def self.fae_fields
    {
      hero_image: { type: Fae::Image },
      hero_text: { type: Fae::TextField },
      introduction: { type: Fae::TextArea },
      body: { type: Fae::TextArea },
      annual_report: { type: Fae::File }
    }
  end

end
```

`app/views/fae/pages/about_us.html.slim`
```ruby
= simple_form_for @item, url: fae.update_content_block_path(slug: @item.slug), method: :put do |f|
  section.main_content-header
    .main_content-header-wrapper
      = render 'fae/shared/form_header', header: @item
      = render 'fae/shared/form_buttons', f: f

  .main_content-sections
    section.main_content-section
      .main_content-section-area
        = fae_input f, :title

        = fae_image_form f, :hero_image
        = fae_content_form f, :hero_text
        = fae_content_form f, :introduction
        = fae_content_form f, :body
        = fae_file_form f, :annual_report
```

Since this is the first page the generator will create `app/controllers/admin/content_blocks_controller.rb`, otherwise it would just add to the `fae_pages` array.


```ruby
module Admin
  class ContentBlocksController < Fae::StaticPagesController

    private

    def fae_pages
      [AboutUsPage]
    end
  end
end
```

## Adding Content Blocks

Chances are you'll need to add content blocks to a page after it's been generated. To do so simply:

- add the new content blocks to `fae_fields` in the `AboutUsPage` model
- add the appropriate form elements to the form at `about_us.html.slim`
	- `fae_content_form` for `Fae::TextField` and `Fae::TextArea`
	- `fae_image_form` for `Fae::Image`
	- `fae_file_form` for `Fae::File`

## Getting Your Content Blocks

Each page generated is a singleton model and each content block is an association to a Fae model.

To get an instance of your page:

```ruby
@about_us_page = AboutUsPage.instance
```

Then to get content from a `Fae::TextField` and `Fae::TextArea`:

```ruby
# for `Fae::TextField` or `Fae::TextArea`
@about_us_page.hero_text.content
# ... or ...
@about_us_page.hero_text_content

# for `Fae::Image` or `Fae::File`
@about_us_page.hero_image.asset.url
# for `Fae::Image` only
@about_us_page.hero_image.asset.alt
@about_us_page.hero_image.asset.caption
```

## Invalid Content Block Names

Content blocks are just associations on the page model, which inherits from `Fae::Page`. Because of this, attributes on `Fae::Page` are invalid names for content blocks. These attributes are:

- title
- slug
- position
- on_prod
- on_stage
- created_at
- updated_at

## Validations on Content Blocks

Since content blocks are setup as associations, adding validations to them can be tricky. To make it easier we setup a method directly in `fae_fields` hash that will dynamically add the validations to the appropriate model and apply the `data-validate` attribute in the form so Judge can  do it's best to validate the content on the frontend.

To add validations to a content block, add a validates option with your rules on a specific content block in `fae_fields`. Format the rules just as you would normal model validations.

`app/models/about_us_page.rb`
```ruby
def self.fae_fields
  {
    hero_image: { type: Fae::Image },
    hero_text: {
      type: Fae::TextField,
      validates: { presence: true }
      },
    introduction: {
      type: Fae::TextArea,
      validates: {
          presence: true,
          length: {
            maximum: 100,
            message: 'should be brief (100 characters or less)'
            }
          }
        },
      },
    body: { type: Fae::TextArea },
    annual_report: { type: Fae::File }
  }
end
```

Validations can only be applied to types `Fae::TextField` and `Fae::TextArea`.

---

# Customization

Fae is meant to allow some radically customization. You can stray completely from Fae's generators and helpers and build your own admin section. However, if you stray from Fae standards you lose the benefit of future bug fixes and feature Fae may provide.

If you need to create custom classes, it's recommended you inherit from a Fae class and if you need to update a Fae class, look for a concern to inject into first.

## Fae Model Concerns

Each one of Fae's models has a built in concern. You can create that concern in your application to easily inject logic into built in models, following Rails' concern pattern. E.g. adding methods to `app/models/concerns/fae/role_concern.rb` will make them accessible to `Fae::Role`.

### Example: Adding OAuth2 logic to Fae::User

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

### Available Fae Concerns

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


## Overriding Classes

If there's no way to inherit from or inject into a Fae class, your last effort would be to override it. To do that, simply copy the Fae class into your application in the same path found in Fae and customize it from there.

E.g. if you need to customize Fae's `image_controller.rb`, copy the file from Fae into your application at `app/controllers/fae/image_controller.rb`.

## Overriding Uploaders

If you need to override the uplodaers `Fae::Image` and `Fae::File` use, you can use the method in the previous section. To customize the `Fae::ImageUploader` just copy file to `app/uploaders/fae/image_uploader.rb` and make your updates.

This is handy when you need to update the `extension_white_list` or set your own resizing logic.

## Custom JS/CSS

Fae creates two files in your assets pipeline that allow custom JS and CSS in your admin.

### fae.js

`app/assets/javascripts/fae.js` compiles into `fae/application.js`. As noted in the file, you can use it as a mainfest (to add a lot of JS) or to simply add JS directly to.

#### Example: fae.js as a Manifest File

```JavaScript
// This file is compiled into fae/application.js
// use this as another manifest file if you have a lot of javascript to add
// or just add your javascript directly to this file
//
//= require admin/plugins
//= require admin/main
```

### fae.scss

`app/assets/stylesheets/fae.scss` compiles into `fae/application.css`. Styles added to this files will be declared before other Fae styles. This file also provide a SCSS variable for Fae's highlight color: `$c-custom-highlight` (which defaults to #31a7e6).

```CSS
// Do Not Delete this page! FAE depends on it in order to set its highlight color.
// $c-custom-highlight: #000;
```

## Overriding The Landing Page

If you want to ignore the default dashboard and make one of your views the landing page you can add a redirect route in your Fae namespace.

`config/routes.rb`
```ruby
# ...
namespace :admin do
  get '/', to: redirect('/admin/people')
  # ...
```

---

# Multiple Language Support

Fae support a language nav that makes managing content in multiple languages easy. The language nav will display all available languages. Clicking a specific language will only display fields specific to that language.

## Configure

To setup the language nav first define all languages Fae will be managing content in.

`config/initializers/fae.rb`
```ruby
config.languages = {
  en: 'English',
  zh: 'Chinese',
  ja: 'Japanese'
}
```

The convention of this hash is important as the keys with have to match the database column suffixes of the specific language fields. The values will be used as the link text in the language nav.

## Database Column Naming

As mentioned above, the column names of fields supporting multiple languages will have to follow this convention:

```
"#{attribute_name}_#{language_abbreviation}`
```

E.g. the english version of the title attribute would be `title_en`.

Using Fae's generators let's quickly scaffold a model that supports multiple languages (columns without suffixes will be treated normally:

```bash
$ rails g fae:scaffold Person name title_en title_zh title_ja intro_en:text intro_zh:text intro_ja:text
```

## Language Nav Partial

Then finally, you'll need to add the `fae/shared/language_nav` partial to the form, as the first child of `section.main_content-header`:

`app/views/admin/people/_form.html.slim`
```slim
= simple_form_for(['admin', @item]) do |f|
  section.main_content-header

    == render 'fae/shared/language_nav'

    .main_content-header-wrapper
    // ...
```

---

# Filtering

If you need to filter your content on your table views, Fae provides a system and helpers to do so.

Using the helpers provided, the filter form will POST to a filter action inherited from `Fae::BaseController`. You can override this action, but by default it will pass the params to a class method in your model called `filter`. It's then up you to scope the data that gets returned and rendered in the table.

Let's walk through an example. Using the `Person` model from above, let's say a person `belongs_to :company` and `has_many :groups`. We'll want to use select filters for companies and groups, and a keyword search to filter by people and company name.

## Route

First, we'll need to add `post 'filter', on: :collection` to our `people` resources:

`config/routes.rb`
```ruby
resources :people do
  post 'filter', on: :collection
end
```

## View Helpers

Next we'll add the form to our view as the first child of `.main_content-section-area`:

`app/views/admin/people/index.html.slim`
```slim
// ...
.main_content-section-area

  == fae_filter_form do
    == fae_filter_select :company
    == fae_filter_select :groups

  table.index_table.main_table-sort_columns
  // ...
```

The search field is built into `fae_filter_form`, but we'll need to provide a `fae_filter_select` for each select element in our filter bar.

Full documentation on both helpers can be found in the [helpers.md](https://bitbucket.org/wearefine/fae/src/master/docs/helpers.md).

## Class Methods

Finally we need to define our class methods to scope the `Person` class. This data will be assigned to `@items` and injected into the table via AJAX.

### filter(params)

`ModelName#filter(params)` will be the scope when data is filtered. The `params` passed in will be the data directly from the `fae_filter_select` helpers we defined, plus `params['search']` from the seach field.

From the form above we can assume our params look like this:

```ruby
{
  'search'  => 'text from search field',
  'company' => 12, # value from company select
  'groups'  => 3 # value from groups select
}
```

So let's use that data to craft our class method.

`app/models/person.rb`
```ruby
def self.filter(params)
  # build conditions if specific params are present
  conditions = {}
  conditions[:company_id] = params['company'] if params['company'].present?
  conditions['groups.id'] = params['groups'] if params['groups'].present?

  # use good 'ol MySQL to seach if search param is present
  search = []
  if params['search'].present?
    search = ["people.name LIKE ? OR companies.name LIKE ?", "%#{params['search']}%", "%#{params['search']}%"]
  end

  # apply conditions and search from above to our scope
  order(:name)
    .includes(:company, :groups).references(:company, :groups)
    .where(conditions).where(search)
end
```

### filter_all

There's also a `ModelName#filter_all` which is called when you reset the filter form. This defaults to the `for_fae_index` scope, but you can override it if you need to.

```ruby
def self.filter_all
  where.not(name: 'John').order(:position)
end
```

---

# Change Tracker

Fae has a build in system to track the changes of the records in your admin. By default it's on, tracking the last 15 times a record has been changed. Make sure any model you want to track has `include Fae::BaseModelConcern` at the top.

For each change the tracker tracks what kind of change it is (create, update or delete), what attributes were changed, who changed it and when it happened.

## Global Options

You can turn off tracking altogether or update how many revisions the tracker keeps with the following options set in `config/initializers/fae.rb`.

| key | type | default | description
|-|-|-|-|
| track_changes | boolean | true | Determines whether or not to track changes on your objects
| tracker_history_length | integer | 15 | Determines the max number of changes logged per object

### Example

`config/initializers/fae.rb`
```ruby
Fae.setup do |config|

  config.tracker_history_length = 10

end
```

## Blacklisting Models and Attributes

If you want to turn off tracking on specific attibutes or a model altogether you can define an optional instance method `fae_tracker_blacklist`.

### Blacklisting a Model

To blacklist an entire model have `fae_tracker_blacklist` return 'all'.

```ruby
class DontTrackMe < ActiveRecord::Base
  include Fae::BaseModelConcern

  def fae_tracker_blacklist
    'all'
  end
end
```

### Blacklisting Attributes

To blacklist specific attributes have 'fae_tracker_blacklist' return an array of attribute names as symbols or strings.

```ruby
class DontTrackMe < ActiveRecord::Base
  include Fae::BaseModelConcern

  def fae_tracker_blacklist
    [:position, :slug]
  end
end
```

## Accessing the Tracked Changes

Each model that includes `Fae::BaseModelConcern` will have the following association:

```
has_many :tracked_changes
```

Each tracked change is a record of `Fae::Change` and has the following attrubtes available

| attribute | description
|-|-|
| `changeable` | a polymorphic association back to the changed record
| `user` | an association to the user that updated the record
| `change_type` | how the record was changed, options are: created, updated or deleted
| `updated_attributes` | an array of attributes changed (for updated records only)
| `updated_at` | when the change occured

### Example Usage

```ruby
@item.tracked_changes.each do |change|
  "This item was #{change.change_type} by #{change.user.first_name} on {change.updated_at}."
end
```

## Display Tracked Changes Table

Fae provides a partial to display tracked changes in an object's form. Read more about `render 'fae/shared/recent_changes'` here:

[https://bitbucket.org/wearefine/fae/src/master/docs/helpers.md#markdown-header-recent_changes](https://bitbucket.org/wearefine/fae/src/master/docs/helpers.md#markdown-header-recent_changes)

---

# CSS Classes

## Fixed position table headers

For extra long tables, add the class `sticky-table-header` to a `table` and scroll away. Multiple sticky tables can appear on one page.

## Collapsible tables

Some pages have multiple tables that are easier to navigate if tables can be shown or hidden. Wrap each table in a `.collapsible` div and prepend an `h3` with the item's name and count. Example below and on the dummy app's `events/index` page.

```slim
.main_content-section-area
  .collapsible
    h3 All Wine (#{@all_wine.length})
    table.index_table
      ....
  .collapsible
    h3 White & Sparkling Wine (#{@white_sparkling_wine.length})
    table.index_table
      ....
```

For best results, include an Open/Close All toggle.

```slim
.main_content-section-area
  .collapsible-toggle Open All
  .collapsible
    ....
```
