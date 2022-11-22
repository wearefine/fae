# Setting Up Images and Files

* [In the Model](#in-the-model)
* [In the Controller](#in-the-controller)
* [In the Form](#in-the-form)
* [In the View](#in-the-view)

---

Are you sick of manually adding SEO fields to every object and page that need them? So are we. The following illustrates how to add this to an existing scaffolded resource, but there is a custom generator field type available that will do all of this for you when you do the initial scaffold generation now, e.g.:

`rails g fae:scaffold Thing name:string seo:seo_set`

## In the Model

Fae provides a model for SEO: `Fae::SeoSet`. This model contains a few very common SEO-related fields and can be polymorphically associated to your application models.

```ruby
has_fae_seo :seo # Can be called anything.
```

## In the Controller

### Building Objects

The SEO model will have to be instantiated as follows in the `build_assets` method that will look familiar for FAE's image/file upload handling:

```ruby
module Admin
  class WinesController < Fae::BaseController

    private

    def build_assets
      if @item.seo.blank?
        @item.build_seo
        @item.seo.build_social_media_image
      end
    end
  end
end
```

## In the Form

### Fae SEO Form

```ruby
section.content
  h2 SEO
  = fae_seo_set_form f, :seo
```

## In the View

```ruby
= object.seo.seo_title
= object.seo.seo_description
= object.seo.social_media_title
= object.seo.social_media_description
= object.seo.social_media_image.asset.url
```

## GraphQL

If your app is GraphQL-enabled, a type will automatically be generated.
