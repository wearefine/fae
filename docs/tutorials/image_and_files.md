# Setting Up Images and Files

* [In the Model](#in-the-model)
* [In the Controller](#in-the-controller)
* [In the Form](#in-the-form)
* [In the View](#in-the-view)

---

Here is everything you need to know about Fae Images and Files:

## In the Model

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

## In the Controller

For a standard Fae section you can pretty much leave your controller empty. Most of the magic happens in [Fae::BaseController](../../app/controllers/fae/base_controller.rb). But there are a few things you should know about.

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

## In the Form

## Fae Image Form

```ruby
fae_image_form
```

![Image upload](https://raw.githubusercontent.com/wearefine/fae/master/docs/images/image.png)

*Fae::Image association only*

| option | type | default | description |
| ------ | ---- | ------- | ----------- |
| label         | string | image_name.to_s.humanize | the uploader's label |
| helper_text         | string | | the uploader's helper text|
| alt_label           | string | "#{image_label} alt text" | the alt field's label |
| alt_helper_text     | string | | the alt field's helper text |
| caption_label       | string | "#{image_label} caption" | the caption field's label |
| caption_helper_text | string | | the caption field's helper text |
| show_alt            | boolean | true | displays the alt field, label, and helper text |
| show_caption        | boolean | false | displays the caption field, label, and helper text |
| required            | boolean | false | adds required validation to the uploader |
| attached_as         | symbol | image_name.to_s | Sets the `attached_as` atrribute on upload. You'll need to customize this if your `attached_as` condition doesn't match the images associaiton name. |

**Examples**

```ruby
fae_image_form f, :logo, label: 'Corporate Logo', required: true
```

## Fae File Form

```ruby
fae_file_form
```

![File upload](https://raw.githubusercontent.com/wearefine/fae/master/docs/images/file.png)

*Fae::File association only*

| option | type | default | description |
| ------ | ---- | ------- | ----------- |
| label         | string | file_name.to_s.humanize | the uploader's label |
| helper_text   | string | | the uploader's helper text|
| required      | boolean | false | adds required validation to the uploader |

image_label: nil, alt_label: nil, caption_label: nil, omit: nil, show_thumb: nil, required: nil, helper_text: nil, alt_helper_text: nil, caption_helper_text: nil


**Examples**

```ruby
fae_file_form f, :tasting_notes_pdf, helper_text: 'PDF format only'
```

## In the View

Images, by default, come with a standard size and a thumbnail size. You can call them in your view like so:

```ruby
= object.image.asset.url
= object.image.asset.thumb.url
```
