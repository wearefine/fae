# Usage

* [Generators](#generators)
* [Models](#models)
* [Nested Resources](#nested-resources)
* [Validation](#validation)
* [Image and File Associations](#image-and-file-associations)
* [Controllers](#controllers)
* [Navigation Items](#navigation-items)
* [Form Helpers](#form-helpers)
* [Pages and Content Blocks](#pages-and-content-blocks)

---

# Generators

Once you have Fae installed, you're ready to start generating your data model. Fae comes with a few generators that work similarly to the ones in Rails. The idea is scaffolding a model with these generators will give you a section to create, edit and delete objects.

## fae:scaffold

```ruby
rails g fae:scaffold [ModelName] [field:type] [field:type]
```
| option | description |
|------- | ----------- |
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
| ------ | ----------- |
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

| option  | description |
|-----------|-------------|
| PageName  | the name of the page |
| field   | the name of the content block |
| type    | the type of the content block (see table below) |

| content block | associated object |
|---------------|-------------------|
| string    | Fae::TextField |
| text      | Fae::TextArea |
| image     | Fae::Image |
| file      | Fae::File |

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
For a standard Fae section you can pretty much leave your controller empty. Most of the magic happens in [Fae::BaseController](../app/controllers/fae/base_controller.rb). But there are a few things you should know about.

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
| --- | ---- | ----------- |
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
[Click here for full documentation on Fae's form helpers](helpers.md#markdown-header-form-helpers)

Generated forms start you off on a good place to manage the object's content, but chances are you'll want to customize them and add more fields as you data model evolves. Fae provides a number of form helpers to help you leverage Fae's built in features will allowing customization when needed.

Form helpers in Fae use the [simple_form](https://github.com/plataformatec/simple_form) gem as it's base. In most cases options that simple_form accepts can be passed into these helpers directly. The reason why we've established these helpers it to allow for customized options. They also provide a method to directly hook into Fae, so we can push out features and bugfixes.

---

# View Helpers and Partials

Fae also provides a number of other built in view helpers and partials, that are documented in [helpers.md](helpers.md).

[Click here for view helpers](helpers.md#markdown-header-view-helpers)
[Click here for Fae partials](helpers.md#markdown-header-fae-partials)

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

[Click here for full documentation on Fae's cloning](cloning.md)

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
  header.content-header
    = render 'fae/shared/form_header', header: @item, f: f

  .content
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

### Configuring a Dynamic Relationship with a Page Model

Here is an example of a pattern you can use to associate objects to your Page models, i.e. for use in a nested form for an item like promos which will exist across many Page objects.

A few things are needed for this to work correctly:

* in the migration you need to add static_page_id as an int column for the new object.

```ruby
add_column :promos, :static_page_id, :integer
```

* in the objects model you need to set the relationship to `:static_page`, with the `class_name` for the Page object.


```ruby
class Promo < ActiveRecord::Base

  belongs_to :static_page, class_name: 'Fae::StaticPage'

end

```

* in the parent Page object model you need to set the relationship to promos with a foreign key.


```ruby

class AboutPage < Fae::StaticPage

  has_many :promos, foreign_key: 'static_page_id'

end

```

* in the Static Page Concern, you will have to surface it by adding `static_page_concern.rb` to the `model/concerns/fae` folder, add a relationship for promos:

```ruby
module Fae
  module StaticPageConcern
    extend ActiveSupport::Concern

    included do
      has_many :promos
    end

  end
end
```

* in the Promo controller you need to set the parent id to `static_page_id`.

```ruby
module Admin
  class PromosController < Fae::ApplicationController
    def new
      @item = Promo.new
      @item.static_page_id = params[:item_id]
      build_assets
    end

 end
end

```

* in the nested table arguments, instead of making the `parent_item` argument item virtual (which is just the instance of the `AboutUsPage`, which we don't have a column in the database for), you need to make the argument related to static pages more broadly.

```ruby
 section.main_content-section
  = render 'fae/shared/nested_table',
    assoc: :promos,
    parent_item: Fae::StaticPage.find_by_id(@item.id),
    cols: [:headline, :body, :link],
    ordered: true
```

Lastly, in the object form be sure to add the `static_page_id` as a hidden field in the promo objects form.

```ruby

= simple_form_for(['admin', @item], html: {multipart: true, novalidate: true, class: 'js-file-form'}, remote: true, data: {type: "html"}) do |f|
  = f.hidden_field :static_page_id

  = f.submit
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
        },
      },
    body: { type: Fae::TextArea },
    annual_report: { type: Fae::File }
  }
end
```

Validations can only be applied to types `Fae::TextField` and `Fae::TextArea`.