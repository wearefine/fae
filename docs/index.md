# Fae Installation and Usage

[TOC]

- pages
- overridding files


## Installation

Add the gem to your Gemfile and run `bundle install`

```ruby
gem 'fae', git: 'git@bitbucket.org:wearefine/fae.git'
```
Run the installer

```bash
$ rails g fae:install
```

After the installer completes, visit `/admin` and setup your first user account. That should atomatically log you in to your blank Fae instance.

### fae:install

Fae's installer will do the following:

- add Fae's namespace and route to `config/routes.rb`
- add `app/assets/stylesheets/fae_variables.scss` for UI color management
- add `app/controllers/concerns/fae/nav_items.rb` to manage main navigation
- add Fae's initializer: `config/initializers/fae.rb`
- add `config/initializers/judge.rb` for validation config
- copies over migrations from Fae
- runs `rake db:migrate`
- seeds the DB with Fae defaults

### DB Seed

Fae comes with a rake task to seed the DB with defaults:

```bash
rake fae:seed_db
```

If you ran the installer, the task will be run automatically. But if you are setting up an established Fae instance locally or deploying to a server, running this will get you setup with some defaults.

### Version management

Fae follows semantic versioning, so you can expect the following format: `major.minor.patch`. Patch versions add bugfixes, minor versions add backwards comapitble features and major versions add non-backward complatible features.

Until Fae is publically released we'll maintain branches for each major release and tag each patch. You can add arguments to the gem claration to help lock in a version if you are running `bundle update`:

```ruby
gem 'fae', git: 'git@bitbucket.org:wearefine/fae.git', branch: 'v1'
gem 'fae', git: 'git@bitbucket.org:wearefine/fae.git', tag: 'v1.0.3'
```

## Generators

Once you have Fae installed, you're ready to start generating your data model. Fae comes with a few generators that work similarly to the ones in Rails. The idea is scaffolding a model with these generators will give you a section to create, edit and delete objects.

### fae:scaffold

```ruby
rails g fae:scaffold [ModelName] [field:type] [field:type]
```
| option | description |
|-|-|
| ModelName | singular camelcased model name |
| field | the attributes column name |
| type | the column type (defaults to `string`), find all options in [Rails' documentaion](http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/TableDefinition.html#method-i-column) |

This is Fae's main generator. It will create the following:

- model
- controller and views for fully CRUDable section
- migration
- resource routes
- link in `app/controllers/concerns/fae/nav_items.rb`

#### Special Attributes

**name**/**title** will automatically be set as the model's `fae_display_field`.

**position** will automatically make the section's index table sortable, be ignored from the form and add acts_as_list and default_scope to the model.

**on_prod**/**on_stage**/**active** will automatically be flag fields in the section's index and ignored in the form.

***_id**/***:references** will automatically be setup as an association in the form.

#### Example

```bash
rails g fae:scaffold Person first_name last_name title body:text date_of_birth:date position:integer on_stage:boolean on_prod:boolean group:references
```


### fae:nested_scaffold

```bash
rails g fae:nested_scaffold [ModelName] [field:type] [field:type] [--parent-model=ParentModel]
```

| option | description |
|-|-|
| `[--parent-model=ParentModel]` | an optional flag that adds the association to the generated model.|

The nested scaffold creates a model that will be nested in another object's form via the `nested_table_advanced` partial. This generator is very similar to `fae:scaffold`, the main difference is in the views that are setup to server the nested form.

### fae:page

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

The page generatator scaffolds a page into Fae's content blocks system. More on that later, for now here's what it does:

- creates or adds to `app/controllers/admin/content_blocks_controller.rb`
- creates a `#{page_name}_page.rb` model
- creates a form view in `app/views/admin/content_blocks/#{page_name}.html.slim`

#### Example

```bash
rails g fae:page AboutUs title:string introduction:text body:text header_image:image
```

## Models

A generated model will start off with sensible defaults based on the attributes you used in the generator. Here are some common custom additions you should be aware of.

### Fae's Base Model Concern

To allow Fae to push out any model specific updates to your application models, include the concern at the top of the class body:

```ruby
class Release < ActiveRecord::Base
  include Fae::Concerns::Models::Base
  # ...
end
```

### fae_display_field

Fae uses `fae_display_field` in a our table views. Defining it as a class method that returns the value of one or multpile attributes is required for those tables to display properly.

If the model is generated, then it will use `name` or `title` by default.

#### Examples

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

### Nested Resources

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

### Validation

Fae doesn't deal with any validation definitions in your application models, you'll have to add those.

#### Judge and Uniquness

Fae uses [Judge](https://github.com/joecorcoran/judge) to automatically add client side validation from the declarations in the models. The caveat is Judge requires you to expose any attributes that have a uniqueness validation. You can do this in `config/initializers/jugde.rb`:

```ruby
Judge.configure do
  expose Release, :name
end
```

### Image and File Associations

Fae provides models for images and files: `Fae::Image` and `Fae::File` rescpectively. These models come with their own attributes, validations and uploaders and can be polymorphically associated to your application models.

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

`-> { where(attached_as: 'bottle_shot') }` sets the scope of the association. If we have more than one `Fae::Image` we need to set the `attached_as` to distiguish it from other images assoicated to that model.

`as: :imageable, class_name: '::Fae::Image'` defines the polymorphic association.

`dependent: :destroy` will make sure the image object is destroyed along with the parent object.

`accepts_nested_attributes_for :bottle_shot, allow_destroy: true` allows the image/file uploader to be nested in the parent object's form in Fae.

#### Other Examples

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

## Controllers

Controllers that manage models in Fae should be namespaced and inherit from `Fae::BaseController`. Controllers that are generated have this already in place:

```ruby
module Admin
  class PeopleController < Fae::BaseController
    # ...
  end
end
```

For a standard Fae section you can pretty much leave your controller empty. Most of the magic happens in [Fae::BaseController](https://bitbucket.org/wearefine/fae/src/master/app/controllers/fae/base_controller.rb). But there are a few things you should know about.

### Building Assets

If the section manages objects with associated images or files, you'll need to build those objects by overridding the `build_assets` private method.

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

### Custom Titles in Views

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


## Form Helpers

[Click here for full documentation on Fae's form helpers](/wearefine/fae/src/master/docs/helpers.md#markdown-header-form-helpers)

Generated forms start you off on a good place to manage the object's content, but chances are you'll want to customize them and add more fields as you data model evolves. Fae provides a number of form helpers to help you leverage Fae's built in features will allowing customization when needed.

Form helpers in Fae use the [simple_form](https://github.com/plataformatec/simple_form) gem as it's base. In most cases options that simple_form accepts can be passed into these helpers directly. The reason why we've established these helpers it to allow for customized options. They also provide a method to directly hook into Fae, so we can push out features and bugfixes.

## View Helpers and Paritals

Fae also provides a number of other built in view helpers and partials, that are documented in [helpers.md](/wearefine/fae/src/master/docs/helpers.md).

[Click here for view helpers](/wearefine/fae/src/master/docs/helpers.md#markdown-header-view-helpers)
[Click here for Fae partials](/wearefine/fae/src/master/docs/helpers.md#markdown-header-fae-partials)

## Custom Helpers

If you want to add your own helper methods for your Fae views, simply create and add them to `app/helpers/fae/fae_helper.rb`. 

```ruby
module Fae
  module FaeHelper
    # ...
  end
end
```

## Content Blocks (aka Pages)

Fae has a built in system to handle content blocks that are statically wired to pages in your site. This is for content that isn't tied to an object in your data model, like home, about and terms content.

The system is just your basic inherited singleton with dynamic polymorphic associations.










