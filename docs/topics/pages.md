# Pages and Content Blocks

Fae has a built in system to handle content blocks that are statically wired to pages in your site. This is for content that isn't tied to an object in your data model, e.g. home, about and terms content.

The system is just your basic inherited singleton with dynamic polymorphic associations. Kidding aside, the complexity of the system is hidden and "it just works&trade;" if you use the generators and/or follow the conventions. This allows for dynamic content blocks that can be added without database migrations and wired up without static IDs!

* [Pages vs Content Blocks](#pages-vs-content-blocks)
* [Generating Pages](#generating-pages)
* [Adding Content Blocks](#adding-content-blocks)
* [Getting Your Content Blocks](#getting-your-content-blocks)
* [Invalid Content Block Names](#invalid-content-block-names)
* [Validations on Content Blocks](#validations-on-content-blocks)

---

## Pages vs Content Blocks

**Pages** are groups of **content blocks** based on the actual pages they appear on the site.

Content blocks are defined in the model and called in the form view. The `type` refers to the generator API (more information available in [the following section](#generating-pages))

| associated object | type | form helper |
| ----------------- | ---- | ----------- |
| Fae::TextField | string | fae_content_form |
| Fae::TextArea | text | fae_content_form |
| Fae::Image | image | fae_image_form |
| Fae::File | file | fae_file_form |

For the following example, we will use a page called `AboutUs`, which will have content blocks for `hero_image`, `title`, `introduction`, `body` and `annual_report`.

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
@about_us_page.hero_image.alt
@about_us_page.hero_image.caption
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

## Linking to Pages Within Fae

Link to the edit screen of a page and its respective content blocks by adding an item to navigation items.

```ruby
def nav_items
  [
    ...
    {
      text: 'Pages', sublinks: [
        { text: 'All', path: fae.pages_path },
        # For example, if `@slug = 'home'`
        { text: 'Home', path: fae.edit_content_block_path('home') }
      ]
    }
    ...
  ]
end
```
