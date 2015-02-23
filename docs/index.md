# Fae Installation and Usage


- controllers
  - set_class_variables
  - build_assets
- form helpers (intro and link to helpers index)
	- slugs
- view helpers (intro and link to helpers index)
- custom helpers with fae_helper.rb
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








###Application Helper Methods

####attr_toggle
The attr_toggle helper method takes an AR object and an attribute. It then creates the html necessary for a working fae on/off toggle switch
```ruby
  attr_toggle item, :on_stage
```
![Alt text](http://www.afinesite.com/fae/documentation/attr_toggle.png')

####form_header
The form_header helper method creates an h1 tag in the format of "params[:action] name"

edit page input: `form_header @user` renders `<%= "<h1>Edit User</h1>" %>`

new page input: `form_header 'Special Releases'` renders `<%= "<h1>New Special Releases</h1>" %>`

####markdown_helper
The markdown_helper supplies a string of markdown helper information

####require_locals
The require_locals method is intended to be used at the beginning of any partial that pulls in a local variable from the page that renders it. It takes a Array of strings containing the variables that are required and the local_assigns view helper method

####image_form
This helper will place a nested form partial in your view, you still need to build the image in your controller
The method takes the form object and the object that attaches to the Image relationship. The following optional params are available:

*<em>image_name</em>: the action image relationships name, defaults to :image
*<em>image_label</em>: defaults to the image_name
*<em>alt_label</em>: defaults to "#{image_label} alt text"
*<em>alt_label</em>: defaults to "#{image_label} alt text"
*<em>omit</em>: an array containing :caption and/or :alt, defaults to [:caption]
*<em>show_thumb</em>: defaults to false
*<em>required</em>: defaults to false
*<em>helper_text</em>: defaults to ""
*<em>alt_helper_text</em>: defaults to ""
*<em>caption_helper_text</em>: defaults to ""

```ruby
  fae_image_form f, :bottle_shot
```
![Alt text](http://www.afinesite.com/fae/documentation/image_form.png')

####fae_date_format
The fae_date_format method takes a Date/DateTime object and an optional timezone string as its second parameter. It simply displays dates in a uniform way accross all implementations.

###Fae Partials

####_index_header.html.erb

* required variables
  * title: <em>string</em>
* optional variables
  * new_button: <em>boolean</em>
  * button_text: <em>string</em>

####_form_buttons.html.erb

* required variables
  * f: <em>form builder</em>
* optional variables
  * item: <em>instance variable for object to be deleted</em>
