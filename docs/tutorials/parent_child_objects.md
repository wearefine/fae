# Setting Up Parent/Child Objects

This is how to setup a parent/child relation with each object having their own fully crudable sections (e.g. not managed in a nested form).

In this example we're going to be using an article and article category relationship. Catgories can be CRUDed in their own sections and articles must be assigned to a category when created. The articles index page will have a table for each category, with the ability to sort articles within each table.

## Scaffold the Objects

First use Fae's generators to scaffold each object:

```bash
rails g fae:scaffold ArticleCategory name position:integer
rails g fae:scaffold Article title body:text position:integer article_category:references
rake db:migrate
```

## Update Models

Then update the models to add associations, validations and `acts_as_list` scope:

```ruby
class ArticleCategory < ApplicationRecord
  include Fae::BaseModelConcern

  acts_as_list add_new_at: :top
  default_scope { order(:position) }

  has_many :articles

  validates :name, presence: true

  def fae_display_field
    name
  end

end
```

```ruby
class Article < ApplicationRecord
  include Fae::BaseModelConcern

  acts_as_list add_new_at: :top, scope: :article_category
  default_scope { order(:position) }

  belongs_to :article_category

  validates :title, presence: true
  validates :article_category, presence: true

  def fae_display_field
    title
  end
end
```

## Update Articles Index

Finally, update the articles index view to nest articles within article categories.

Get articles via article categories in the controller:

```ruby
module Admin
  class ArticlesController < Fae::BaseController

    def index
      @article_categories = ArticleCategory.joins(:articles).uniq
    end

  end
end
```

Use the collapsible table styles for a clean multiple table view:

```slim
== render 'fae/shared/index_header', title: @klass_humanized.pluralize.titleize

main.content
  .collapsible-toggle.close-all Close All
  - if @article_categories.present?
    - @article_categories.each do |category|
      .collapsible.active
        h3 = category.name
        table.js-sort-row
          thead
            tr
              th.th-sortable-handle
              th Title
              th.-action-wide Modified
              th.-action data-sorter="false"

          tbody
            - category.articles.each do |item|
              tr id=fae_sort_id(item)
                td.sortable-handle: i.icon-sort
                td = link_to item.fae_display_field, edit_admin_article_path(item)
                td = fae_date_format item.updated_at
                td = fae_delete_button item
```

## Accessing Articles in the Frontend

Articles will be ordered automatically in the scope of their category. When you retrieve them on the frontend, it will be assumed it's in the context of their category. That way you won't have to worry about overlapping positions.
