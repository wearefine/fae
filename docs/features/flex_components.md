# Flex Components

Fae now offers a system to support a "page builder" experience for admins with the concept of Flex Components. At it's core, the Flex Component model is a polymorphic join model that ties the actual component models to the owning object or `Fae::StaticPage` instance.

---

## Installation

This is an opt-in feature. The installer will add the necessary files to the mounting application and run a migration.

```bash
rails g fae:install_flex_components
```

## Generator

To create a flex component, there's a new generator.

```bash
rails g fae:flex_component HeroComponent heading:string logo:image
```

This will scaffold everything necessary for the new component, and make it available for selection in the component lists in forms.

![Image upload](https://raw.githubusercontent.com/wearefine/fae/7220461e0dbb9c503c633749746d703ab89045a5/docs/images/flex_components_select.png)

If your app is GraphQL enabled, it will also create a type and add the type class name to the `flex_component_union_type.rb` `possible_types` definition, so the new component will be available on the API without any manual code changes.

## Adding Flex Components to Models/Pages

### Models

The installation added a model concern, `models/concerns/flex_componentable_concern.rb` which contains the association definition. Include this in your models to give them Flex Components.

```ruby
class Wine < ActiveRecord::Base
  include Fae::BaseModelConcern
  include FlexComponentableConcern
```

### Fae::StaticPage

Since extending the `Fae::StaticPage` model is done through the `models/concerns/static_page_concern.rb`, if you intend to use Flex Components in static pages, you'll need to add the association definitions there:

```ruby
module Fae
  module StaticPageConcern
    extend ActiveSupport::Concern

    included do
      has_many :flex_components, as: :flex_componentable, dependent: :restrict_with_error
    end
```

## Forms

In the form, Flex Components will behave like any other Fae nested scaffold. A new Fae partial is used for adding nested lists of Flex Components to forms:

```ruby
= simple_form_for([:admin, @item], html: { 'data-form-manager-model' => @item.class.name, 'data-form-manager-info' => (@form_manager.present? ? @form_manager.to_json : nil) }) do |f|
  == render 'fae/shared/form_header', header: @klass_name, languages: true

  main.content
  # The rest of your form

# Flex Components nested table
- if @item.persisted?
  section.content#components
    == render 'fae/shared/flex_components_table',
      assoc: :flex_components,
      parent_item: @item
```

## GraphQL

If your app is GraphQL enabled and you want a type to expose its Flex Components, add a field for them:

```ruby
field :flex_components, [Types::FlexComponentType], null: true
```


Here's a brief example of a query utilizing Flex Components on a static page:

```GraphQL
{
  componentPage {
    flexComponents {
      instance {
        __typename
        ... on HeroComponent {
          title
        }
        ... on TextComponent {
          name
        }
      }
    }
  }
}
```