# Filtering

If you need to filter your content on your table views, Fae provides a system and helpers to do so.

Using the helpers provided, the filter form will POST to a filter action inherited from `Fae::BaseController`. You can override this action, but by default it will pass the params to a class method in your model called `filter`. It's then up you to scope the data that gets returned and rendered in the table.

Let's walk through an example. Using the `Person` model from above, let's say a person `belongs_to :company` and `has_many :groups`. We'll want to use select filters for companies and groups, and a keyword search to filter by people and company name.

* [View Helpers](#view-helpers)
* [Class Methods](#class-methods)
* [Fae Filter Form](#fae-filter-form)
* [Fae Filter Select](#fae-filter-select)

---

## Route

First, we'll need to add `post 'filter', on: :collection` to our `people` resources:

`config/routes.rb`
```ruby
resources :people do
  post 'filter', on: :collection
end
```

## View Helpers

Next we'll add the form to our view as the first child of `.content`:

`app/views/admin/people/index.html.slim`
```slim
// ...
.content

  == fae_filter_form do
    == fae_filter_select :company
    == fae_filter_select :groups

  table.js-sort-column
  // ...
```

The search field is built into `fae_filter_form`, but we'll need to provide a `fae_filter_select` for each select element in our filter bar.

## Class Methods

Finally we need to define our class methods to scope the `Person` class. This data will be assigned to `@items` and injected into the table via AJAX.

### filter(params)

`ModelName#filter(params)` will be the scope when data is filtered. The `params` passed in will be the data directly from the `fae_filter_select` helpers we defined, plus `params['search']` from the search field.

From the form above we can assume our params look like this:

```ruby
{
  'search'  => 'text from search field',
  'company' => 12, # value from company select
  'groups'  => 3 # value from groups select
}
```

So let's use that data to craft our class method.

`app/models/person.rb`
```ruby
def self.filter(params)
  # build conditions if specific params are present
  conditions = {}
  conditions[:company_id] = params['company'] if params['company'].present?
  conditions['groups.id'] = params['groups'] if params['groups'].present?

  # use good 'ol MySQL to search if search param is present
  search = []
  if params['search'].present?
    search = ["people.name LIKE ? OR companies.name LIKE ?", "%#{params['search']}%", "%#{params['search']}%"]
  end

  # apply conditions and search from above to our scope
  order(:name)
    .includes(:company, :groups).references(:company, :groups)
    .where(conditions).where(search)
end
```

### filter_all

There's also a `ModelName#filter_all` which is called when you reset the filter form. This defaults to the `for_fae_index` scope, but you can override it if you need to.

```ruby
def self.filter_all
  where.not(name: 'John').order(:position)
end
```

## Fae Filter Form

```ruby
fae_filter_form
```

![Filter form](../images/filter_form.png)

Displays the filter form, which includes the search field, submit, and reset buttons. It accepts options, followed by an optional block.

| option | type    | default                                | description |
|--------|---------|----------------------------------------|-------------|
| action | string  | "#{@index_path}/filter" | the path the form submits to |
| title  | string  | "Search #{@klass_humanized.pluralize.titleize}" | the h2 text in the filter form |
| search | boolean | true                                   | displays the search field |
| cookie_key | string | false | set your cookie name on the fae_filter_form if you want to persist the selected filtered state |


**Examples**

```slim
== fae_filter_form title: 'Search some stuff', search: false do
  // optional form elements
```

## Fae Filter Select

```ruby
fae_filter_select
``(attribute, options)`

![Filter select](../images/filter_select.png)

Dislays a select tag to be used within a `fae_filter_form`.

| option       | type                    | default                        | description |
|--------------|-------------------------|--------------------------------|-------------|
| label        | string                  | attribute.to_s.titleize        | label on select |
| collection   | ActiveRecord collection | AttributeAsClass.for_fae_index | the collection of AR objects to populate the select options |
| label_method | symbol                  | :fae_display_field             | the attribute to use as the label in the select options |
| placeholder  | string or boolean       | "All #{options[:label]}"       | the blank value in the select. It can be set to false to disable |
| options      | array                   | []                             | an alternative array of options if the options aren't an ActiveRecord collection |
| grouped_options | array                | []                             | an alternative array of grouped options if the options aren't an ActiveRecord collection |
| grouped_by   | symbol                  |                                | a Fae association on the models in `collection`. The association must have a `fae_display_name` method |

**Examples**

```slim
== fae_filter_form do
  == fae_filter_select :group, label: 'Groupings', collection: Groups.for_filters
  == fae_filter_select :group, label: 'Groupings', collection: Groups.for_filters, grouped_by: :filter
```
