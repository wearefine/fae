# Controllers and Concerns

Controllers that manage models in Fae should be namespaced and inherit from `Fae::BaseController`. Controllers that are generated have this already in place:

```ruby
module Admin
  class PeopleController < Fae::BaseController
    # ...
  end
end
```
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

## Custom Titles in Views

If you'd like to change the generated titles in the Fae views, you can do so with the following `before_action`.

```ruby
module Admin
  class WinesController < Fae::BaseController
    before_action do
      set_class_variables 'Vinos'
    end
  end
end
```

This will affect the add button text and index/form page titles.