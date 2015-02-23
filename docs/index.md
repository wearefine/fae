# Fae Installation and Usage

- installation (yes again)
- generators
- models
	- Fae::Concerns::Models::Base
	- fae_display_field
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

```ruby
rails g fae:nested_scaffold [ModelName] [field:type] [field:type] [--parent-model=ParentModel]
```

| option | description |
|-|-|
| `[--parent-model=ParentModel]` | an optional flag that adds the association to the generated model.|

The nested scaffold creates a model that will be nested in another object's form via the `nested_table_advanced` partial. This generator is very similar to `fae:scaffold`, the main difference is in the views that are setup to server the nested form.

### fae:page

```ruby
rails g fae:page [page_name] [field:type] [field:type]
```

| option 	| description |
|-----------|-------------|
| page_name | the name of the page |
| field 	| the name of the content block |
| type 		| the type of the content block (see table below) |

| content block | associated object |
|---------------|-------------------|
| string 		| Fae::TextField |
| text 			| Fae::TextArea |
| image			| Fae::Image |
| file			| Fae::File |





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
