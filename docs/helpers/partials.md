# Fae Partials

* [Index Header](#index-header)
* [Form Header](#form-header)
* [Form Buttons](#form-buttons)
* [Nested Table](#nested-table)
* [Nested Forms](#nested-forms)
* [Recent Changes](#recent-changes)

---

## Index Header

```ruby
index_header
```

Displays page title, add button, and flash messages.

| option | type | default | description |
| ------ | ---- | ------- | ----------- |
| nested | boolean | false | converts normal add button to nested add button
| title | string | @klass_humanized.pluralize.titleize | the page's H1 |
| new_button | boolean | true | displays the add button |
| button_text | string | "Add #{title.singularize}" | add button text |
| csv | boolean | false | adds export to csv button |
| breadcrumbs | boolean | true | display breadcrumb navigation before title |

**Examples**

Standard implementation
```ruby
render 'fae/shared/index_header'
```

Custom header
```ruby
render 'fae/shared/index_header', title: 'Something Entirely Different', new_button: false, csv: true
```

## Form Header

```ruby
form_header
```

![Form header](https://raw.githubusercontent.com/wearefine/fae/master/docs/images/form_header.png)

Displays breadcrumb links and form title.

| option | type | default | description |
| ------ | ---- | ------- | ----------- |
| header | ActiveRecord object or string | | **(required)** passed to form_header helper method |
| languages | boolean | false | display the [language changer](../features/multi_language.md) |
| save_button_text (`v1.3 <=`)   | string | 'Save' | save button text |
| cancel_button_text (`v1.3 <=`) | string | 'Cancel' | cancel button text  |
| cloneable | boolean | false | includes Clone button |
| clone_button_text | string | 'Clone' | clone button text |
| subnav | Array<String> | [] | generates "jump to" anchor links for long forms |

If `subnav` is supplied, sections within the form must include IDs matching the [parameterized](http://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-parameterize) items. Note that `parameterize` will use `_` as a separator.

```slim
- subnav_array = ['SEO']
- subnav_array.concat ['Nested Image Gallery', 'Recent Changes'] if params[:action] == 'edit'
= render 'fae/shared/form_header', header: @klass_name, subnav: subnav_array

section.content#attributes
  ...
section.content#nested_image_gallery
  ...
section.content#recent_changes
  ...
```

To separate name and ID selector, pass an Array instead of a String.

```ruby
- subnav_array = ['SEO', 'Attributes', ['Images', 'images_table']]
```

**Examples**

Standard implementation
```ruby
render 'fae/shared/form_header', header: @item, subnav: ['SEO', 'Image Gallery', 'Recent Changes']
```

## Form Buttons

```ruby
form_buttons
```
**Warning**: This partial will be depreceated in v2.0. Use [`fae/shared/form_header`](#form_header-1) instead.

Displays form's save and cancel buttons.

| option | type | default | description |
| ------ | ---- | ------- | ----------- |
| save_button_text   | string | 'Save' | save button text  |
| cancel_button_text | string | 'Cancel' | cancel button text  |

**Examples**

Standard implementation
```ruby
render 'fae/shared/form_buttons'
```

With custom text
```ruby
render 'fae/shared/form_buttons', save_button_text: 'Yes!', cancel_button_text: 'Nope :('
```

## Nested Table

```ruby
nested_table
```

The nested table works in tandem with a nested model, typically created by the nested scaffold generator, to display a nested ajax form for creating associated items in the edit form.

The nested_table should go after the main form ends and should only be placed on the edit page (it requires the parent_item to be present to associate new items to).

| option | type | default | description |
|--------|------|---------|-------------|
| index | false | boolean | used for nested index forms |
| assoc   | symbol | | **(required)** the association's name, or the item's name if it's for the index  |
| parent_item | ActiveRecord object | | **(required)** the item that the new objects will be associated to  |
| cols* | array of symbols, or array of symbols and hashes | [], [{}] | an array of attributes to display on the list view, associations will display the `fae_display_field` or a thumbnail if it's a `Fae::Image` |
| title | string | assoc.to_s.humanize | the H3 directly above the form |
| add_button_text | string | "Add #{title.singularize}" | the add button's text |
| ordered | boolean | false | allows list view to be sortable, which is saved to a `position` attribute |
| has_thumb | boolean | false | displays a thumbnail in the list view (only applicable to `Fae::Image`)
| edit_column | boolean | false | displays edit link
| assoc_name | string | assoc.to_s | the stringified association name, which is used in the paths. **only update if you know what you're doing** |
| helper_text | string | '' | the h6 directly above the nested table and below the tite, which is used to provide the user with some helper_text to describe the context |
| new_path | string | "new_#{fae_path}_#{assoc_name_singular}_path" | the path that the application will hit when creating a new object inside the nested table, which is used to provide the user with the ability to pass in some params |

***Example**

* cols option now accepts hashes for custom titles, using attr: and title:
```ruby
cols: [{ attr: :name, title: 'What did you call me?' }, :image, :title]
```

You may also pass in custom columns, like an association's count by first defining a method on the model, then passing it in to the cols option.

**Example**
```ruby
def cat_size
  cats.size.to_s
end

cols: [{ attr: :cat_size, title: 'Kitten Count' }]
```

**Examples**

Full Slim implementation with section wrapper and edit page conditional
```slim
- if params[:action] == 'edit'
  section.content
    = render 'fae/shared/nested_table',
      assoc: :tasting_notes,
      parent_item: @item,
      cols: [:name, :author, :live],
      ordered: true,
      new_path: "/admin/winemakers/new?region_type=#{region_type}"
```

## Nested Forms

![Nested Table](https://raw.githubusercontent.com/wearefine/fae/master/docs/images/nested_table.png)

Fae provides an easy way to manage associated objects in one form via nested forms. A good use case for nested forms is when you have a `has_many` association where the child object is simple enough that an embedded table and form on the parent form will do. This makes managing the associated content much more convenient.

Some good examples ideal for nested tables are image galleries, tasting notes on a wine release and quotes on a person object.

## Setting Up a Nested Form

### Generate the child object

Assuming the parent object already exists, generate the object to be nested with [Fae's nested scaffold command](../topics/generators.md).

### Update Models

Add the `has_many` association to the parent model. On the child model make sure the `belongs_to` and `fae_nested_parent` have been defined. This will happen automatically if you use the `--parent-model` flag on the nested scaffold command.

#### fae_nested_parent

`fae_nested_parent` is an instance method on the child model that tells the controller how to access the parent. The method should return a symbol of the defined `belongs_to` association.

```ruby
def fae_nested_parent
  :person
end
```

### Update Child Form View

Update the elements you wish to appear in the nested form.

### Update Parent Form View

Add the [nested table partial](helpers.md#nested_table) to the parent form. This partial should be below the actual form as you cannot nest form tags. This form should only appear on the edit page as you cannot associate content to an object that doesn't exist yet.

## Recent Changes

```ruby
recent_changes
```

![Recent changes](https://raw.githubusercontent.com/wearefine/fae/master/docs/images/recent_changes.png)

Displays recent changes to an object as logged by the change tracker in a table. Columns include the user, type, updated attributes, and datetime of the change.

This partial is best placed at the bottom of the form and will automatically hide itself in create forms, where there wouldn't be changes to display.

**Examples**

Standard implementation
```ruby
= render 'fae/shared/recent_changes'
```

Optionally, you can add a link to it in the form nav:
```slim
= render 'fae/shared/form_header', ..., subnav: [...,  'Recent Changes']
```
