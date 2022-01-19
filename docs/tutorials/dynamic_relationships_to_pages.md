# Adding Dynamic Relationships to Static Pages

Here is an example of a pattern you can use to associate objects to your Page models, i.e. for use in a nested form for an item like promos which will exist across many Page objects.

A few things are needed for this to work correctly:

* in the migration you need to add static_page_id as an int column for the new object.

```ruby
add_column :promos, :static_page_id, :integer
```

* in the Static Page Concern, you will have to surface it by adding `static_page_concern.rb` to the `model/concerns/fae` folder, add a relationship for promos:

```ruby
module Fae
  module StaticPageConcern
    extend ActiveSupport::Concern

    included do
      has_many :promos, foreign_key: 'static_page_id'
    end

  end
end
```

* in the objects model you need to set the relationship to `:static_page`, with the `class_name` for the Page object.

```ruby
class Promo < ActiveRecord::Base

  belongs_to :static_page, class_name: 'Fae::StaticPage', optional: true

end

```

* in the objects controller you need to inherit from `Fae::NestedBaseController` instead of `Fae::BaseController`

```ruby
module Admin
  class PromosController < Fae::NestedBaseController
  end
end
```

* in the Promo model you need to set the fae_nested_parent to `:static_page`.

```ruby
def fae_nested_parent
  :static_page
end
```

* in the nested table arguments, instead of making the `parent_item` argument item virtual (which is just the instance of the `AboutUsPage`, which we don't have a column in the database for), you need to make the argument related to static pages more broadly.

```ruby
 section.content
  = render 'fae/shared/nested_table',
    assoc: :promos,
    parent_item: Fae::StaticPage.find_by_id(@item.id),
    cols: [:headline, :body, :link],
    ordered: true
```

* The nested form can be wrapped in a class `.nested-form` for a more inline look.

```ruby
  .nested-form
    h2 New Promo
    == render 'form
```

Lastly, in the object form be sure to add the `static_page_id` as a hidden field in the promo objects form.

```ruby

= simple_form_for([:admin, @item], html: {multipart: true, novalidate: true, class: 'js-file-form'}, remote: true, data: {type: "html"}) do |f|
  = f.hidden_field :static_page_id

  = f.submit
```
