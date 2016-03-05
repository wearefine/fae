# Customization

* [Overview](#overview)
* [Multiple Language Support](#multiple-language-support)
* [Filtering](#filtering)
* [Change Tracker](#change-tracker)
* [CSS Classes](#css-classes)
* [Cloning](#cloning)
* [Conditional Validation](#conditional-validation)

---

# Overview

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

Next we'll add the form to our view as the first child of `.content`:

`app/views/admin/people/index.html.slim`
```slim
// ...
.content

  == fae_filter_form do
    == fae_filter_select :company
    == fae_filter_select :groups

  table.main_table-sort_columns
  // ...
```

The search field is built into `fae_filter_form`, but we'll need to provide a `fae_filter_select` for each select element in our filter bar.

Full documentation on both helpers can be found in the [helpers.md](helpers.md).

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

| key | type | default | description |
| --- | ---- | ------- | ----------- |
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

| attribute | description |
| --------- | ----------- |
| `changeable` | a polymorphic association back to the changed record |
| `user` | an association to the user that updated the record |
| `change_type` | how the record was changed, options are: created, updated or deleted |
| `updated_attributes` | an array of attributes changed (for updated records only) |
| `updated_at` | when the change occured |

### Example Usage

```ruby
@item.tracked_changes.each do |change|
  "This item was #{change.change_type} by #{change.user.first_name} on {change.updated_at}."
end
```

## Display Tracked Changes Table

Fae provides a partial to display tracked changes in an object's form. Read more about `render 'fae/shared/recent_changes'` here:

[helpers.md#markdown-header-recent_changes](helpers.md#markdown-header-recent_changes)

---

# CSS Classes

## Collapsible tables

Some pages have multiple tables that are easier to navigate if tables can be shown or hidden. Wrap each table in a `.collapsible` div and prepend an `h3` with the item's name and count. Example below and on the dummy app's `events/index` page.

```slim
.content
  .collapsible
    h3 All Wine (#{@all_wine.length})
    table
      ....
  .collapsible
    h3 White & Sparkling Wine (#{@white_sparkling_wine.length})
    table
      ....
```

For best results, include an Open/Close All toggle.

```slim
.content
  .collapsible-toggle Open All
  .collapsible
    ....
```

---

# Cloning

So you want to easily, automagically clone a record and its children? Lucky for you, we made it easy to do that! You're welcome.

## Basic

The most basic implementation of this feature clones the record, all it's attributes (except id, created and updated at) and any belongs_to associations via foreign_keys. We also check for any uniqueness validators on your attributes and rename them to "attribute-#", starting at 2, for your convenience.

## Add Buttons

You may add the clone button to the index, edit form, or both.

**Examples**

#### For Index

Add the following to your `thead`, usually after 'Delete':

```slim
  th.-clone data-sorter="false" Clone
```

And to your `tbody`:

```slim
td = fae_clone_button item
```

#### For Form

Simply pass `cloneable: true` into your form_header partial. You may also edit the default text 'Clone', by passing in `clone_button_text` and your own string.

```ruby
  render 'fae/shared/form_header', cloneable: true, clone_button_text: 'Duplicate Me!'
```

That's all for basic set-up.

## Advanced

If you want complete control over which attributes and associations are cloned, we wouldn't call you a control freak. We've baked in some nice simple methods to make this possible.

**Note:** Asset cloning is not currently supported, so if you try to pass in those associations, cloning will fail.

## Whitelisting Attributes

If you want to whitelist attributes to be cloned, you may add the `attributes_for_cloning` method into your controller's private method. Just pass in an array of symbols and we will take care to only copy those attributes over.

**Note:** please make sure to include _everything_ that is required, or the record will fail to get created. You've been warned.

**Example**

```ruby
def attributes_for_cloning
  [:name, :slug, :description, :wine_id]
end
```

## Cloning Associations

Belongs_to associations are automatically copied over, unless you are whitelisting attributes and forget to/ purposely don't add it there. For the rest of the associations you may have (i.e. has_one, has_many, has_and_belongs_to_many, has_many_through), you may use the `associations_for_cloning` method by passing in array of symbols.

**Note:** Any images or files you have will **not** be copied along, if you have included those relationships.

**Example**

```ruby
def associations_for_cloning
  [:aromas, :events]
end
```

That's it! Happy cloning. :)

## Conditional Validation

In order to add validation that is conditional you must configure FAE and [Judge](https://github.com/joecorcoran/judge#writing-your-own-eachvalidator) by using custom `eachValidators`.

Once you've done this you can require a field based on the value of another. For example: if you only want to require a `slug` field if you check `detail page` checkbox on a project object.

To start, add a validator in the the `app/validator/` with a file name like `detail_page_validator.rb`

```ruby
class DetailPageValidator < ActiveModel::EachValidator
  uses_messages :no_detail_page

  def validate_each(record, attribute, value)
    if record.detail_page && value.blank?
      record.errors.add(attribute, :no_detail_page)
    end
  end
end
```

Next, update your model to use the `detail_page` validation:

```ruby
class Project < ActiveRecord::Base
  validates :name, presence: true
  validates :slug, detail_page: true
end
```

In your form view nest the optional fields, and add some classes for js and sass. In this case we are looking at the project form.

```ruby
= simple_form_for(['admin', @item]) do |f|
  ...

  .main_content-sections
    section.main_content-section
      .content
        = fae_input f, :name
        = fae_input f, :detail_page, helper_text: "This project has a detail page and should display on the Work category page(s)"
        .js-optional-fields class=("#{ 'hidden' unless (params[:action] == 'edit' && @item.detail_page?) }")
          = fae_input f, :slug, label_html: { class: 'is_required_and_hidden'}
```

Update Judge so that judge loads your custom `EachValidtor` on the FE.

```javascript
var Validator = {

    init: function() {
      judge.eachValidators.detail_page = function(options, messages) {
        var errorMessages = [];
        // 'this' refers to the form element
        is_checked = $('#project_detail_page').prop("checked") === true;
        if ( is_checked && (this.value === undefined || this.value === "")) {
          errorMessages.push(messages.no_detail_page);
        }
        return new judge.Validation(errorMessages);
      };
    }
};
```

In `fae.scss` add in some styles for the `hidden` and `is_required_and_hidden` classes.

```sass
// Do Not Delete this page! FAE depends on it in order to set its highlight color.
$c-custom-highlight: #e6253c;

.hidden {
  display: none;
}

label.is_required_and_hidden {
  &:before {
    content: '* ';
    color: $c-custom-highlight;
  }
}
```

In `fae.js` add in code for the toggling of the button detail page button to show and hide your conditionally required fields. Be sure to require validator js at the top.

```javascript
//= require validator

var AcmeAdmin = {

  init: function() {
    Validator.init();
    var _this = this;
    if ( $('body.projects').length && $('body.projects.index').length === 0 ) {
      _this.check_for_detail_page("#project_detail_page");
      _this.project_edit_listener();
    }
  },

  project_edit_listener: function() {
    var _this = this;
    $("#project_detail_page").click(function(){
      _this.check_for_detail_page($(this));
    });
  },

  check_for_detail_page: function(field) {
    if ($(field).is(':checked')) {
      $('.js-optional-fields').removeClass('hidden');
    } else {
      $('.js-optional-fields').not('hidden').addClass('hidden');
      $('.js-optional-fields').find('input').val('');
    }
  }

};

$(document).ready(function() {
  AcmeAdmin.init();
});
```