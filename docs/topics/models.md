# Models

* [Models](#models)
* [Nested Resources](#nested-resources)
* [Validation](#validation)
* [Image and File Associations](#image-and-file-associations)

---

## Models

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

![Validation](https://raw.githubusercontent.com/wearefine/fae/master/docs/images/length_validation.gif)

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

