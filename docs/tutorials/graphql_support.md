# Setting up GraphQL with Fae

Adding GraphQL to your Fae CMS is a simple way to make make it headless. GraphQL is a query language that allows you to query your API and only get back the data you need. To learn more about GraphQL, visit https://graphql.org/.

For Rails apps, we recommend using the awesome `graphql` gem used by GitHub, Shopify and Kickstarter. This gem is a Ruby implementation that provides an easy way to define your graph along with a built in API endpoint served directly from your app.

https://graphql-ruby.org/

* [Installation](#installation)
* [Types for Generated Objects](#types-for-generated-objects)
* [And Beyond](#and-beyond)

## Installation

Add and bundle install the gem:

```ruby
gem 'graphql'
```

Setup the base GraphQL files:

```bash
rails generate graphql:install
```

Add Fae specific GraphQL types for `Fae::Image` and `Fae::File` to your parent app.

`app/graphql/types/fae_image_type.rb`
```ruby
class Types::FaeImageType < Types::BaseObject

  graphql_name 'FaeImage'
  description 'A Fae::Image object'

  field :id, ID, null: false
  field :asset_url, String, null: true
  field :asset_thumb_url, String, null: true
  field :caption, String, null: true
  field :alt, String, null: true
  field :file_size, Integer, null: true
  field :created_at, String, null: false
  field :updated_at, String, null: false

  # you can add custom methods to access Carrierwave versions
  def asset_thumb_url
    object.asset.thumb.url || object.asset_url if object.asset.present?
  end

end
```

`app/graphql/types/fae_file_type.rb`
```ruby
class Types::FaeFileType < Types::BaseObject

  graphql_name 'FaeFile'
  description 'A Fae::File object'

  field :id, ID, null: false
  field :asset_url, String, null: true
  field :file_size, Integer, null: true
  field :created_at, String, null: false
  field :updated_at, String, null: false
end
```

### Optional GraphiQL Setup

Optionally, we recommend installing and using [GraphiQL for Rail](https://github.com/rmosolgo/graphiql-rails), which provides GraphQL documentaion and sandbox directly in your app.

## Types for Generated Objects

If you have the `graphql` gem installed, GraphQL types will be generator for you when you use Fae's generators.

If you have already generated your objects, you can manually create them based on these examples.

Here is an example of a generated type for a regular object:

```ruby
class Types::ReleaseType < Types::BaseObject

  graphql_name 'Release'

  field :id, ID, null: false
  field :name, String, null: true
  field :has_detail_page, Boolean, null: true
  field :slug, String, null: true
  field :body, String, null: true
  field :seo_title, String, null: true
  field :seo_description, String, null: true
  field :social_media_description, String, null: true
  field :bottle_shot, Types::FaeImageType, null: true
  field :sell_sheet_pdf, Types::FaeFileType, null: true
  field :tier, Types::TierType, null: true
  field :created_at, String, null: false
  field :updated_at, String, null: false
end
```

Here is a generated type for a `Fae::StaticPage`:

```ruby
class Types::HomePageType < Types::BaseObject

  graphql_name 'HomePage'

  field :title, String, null: false
  field :header, String,
    null: true,
    method: :header_content
  field :body, String,
    null: true,
    method: :body_content
  field :hero_image, Types::FaeImageType, null: true
  field :welcome_pdf, Types::FaeFileType, null: true
end
```

## And Beyond

After your base objects are setup, you'll need to define your query types and schema. The GraphQL Ruby guide is a great place to start.

https://graphql-ruby.org/getting_started






