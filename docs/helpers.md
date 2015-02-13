# Helpers

[TOC]

## Form Helpers

Form helpers in Fae use the [simple_form](https://github.com/plataformatec/simple_form) gem as it's base. In most cases options that simple_form accepts can be passed into these helpers directly. The reason why we've established these helpers it to allow for customized options. They also provide a method to directly hook into Fae, so we can push out features and bugfixes.

### Format

All form helpers are in the following format:

```ruby
fae_method_name(f, attribute, options)
```

| argument | description |
|-|-|
| f | **(required)** The variable simple_form passes through in it's block. The actual variable can vary based on how you setup the view, but `f` is the generated default. |
| attribute | **(required)** The attribute the form element is displaying. It's recommended you use symbols over strings. |
| options | An optional hash of options to customize the form element. |

#### Global Options

| option | type | default | description |
|-|-|-|-|-|
| label | string | attribute.humanize | the form label |
| helper_text | string | | helper text that appears under label |
| hint | string | | text that appears in a hint modal (cannot be combined with `dark_hint`) |
| dark_hint | string | | text that appears in a dark color scheme (cannot be combined with `hint`) |
| markdown | boolean | | activator for the modal helper text |
| input_class | string | | a class to add to the input element |
| wrapper_class | string | | a class to add to the wrapper element |
| validate | boolean | true | triggers `judge` to validate element |


### fae_input(f, attribute, options)

*attributes only*

fae_input is the basic input method derived from simple_form's f.input. What it displays will depend on the column type of the attribute. See [simple_form's documentation](https://github.com/plataformatec/simple_form#available-input-types-and-defaults-for-each-column-type) to learn more.


**Examples**

An input[type=text] with an added wrapper_class and helper_text:
```ruby
fae_input f, :first_name, wrapper_class: 'special_wrapper', helper_text: 'No more than 50 characters'
```

A textarea with Fae's built-in markdown hint:
```ruby
fae_input f, :description, hint: markdown_helper
```

### fae_association(f, attribute, options)

*associations only*

fae_association is directly derived from simple_form's f.association. Again, the element it renders deplends on the association type.

| option | type | default | description |
|-|-|-|-|-|
| collection | array or AR:Relation | AssociationClass.all | an array or ActiveRecord object of items to populate the element |

**Examples**

A dropdown listing active people
```ruby
fae_association f, :people, collection: Person.active
```

### fae_checkbox(f, attribute, options)

| option | type | default | description |
|-|-|-|-|-|
| type | 'stacked' or 'inline' | stacked | determines how multiple checkboxes are displayed |

### fae_radio(f, attribute, options)

| option | type | default | description |
|-|-|-|-|-|
| type | 'stacked' or 'inline' | stacked | determines how multiple checkboxes are displayed |

### fae_pulldown(f, attribute, options)

| option | type | default | description |
|-|-|-|-|-|
| collection | array or AR:Relation | AssociationClass.all | an array or ActiveRecord object of items to populate the element |
| size | 'long' or 'short' | long | determines the size of the pulldown |
| search | boolean | search is displayed with more than 10 items | determines whether or not to show the search bar |

### fae_multiselect(f, attribute, options)

*associations only*

| option | type | default | description |
|-|-|-|-|-|
| two_pane | boolean | false | By default this will display a chosen style multiselect, setting this to true will display the 'two pane' style. |

### fae_grouped_select(f, attribute, options)

| option | type | default | description |
|-|-|-|-|-|
| collection | array or AR:Relation | AssociationClass.all | an array or ActiveRecord object of items to populate the element |
| groups | array of strings | | must be used with labels |
| labels | array of strings | | must be used with groups |

### fae_datepicker(f, attribute, options)

*attributes only*

### fae_daterangepicker(f, attribute, options)

*attributes only*

| option | type | default | description |
|-|-|-|-|-|
| start_date | symbol | | start date for the date picker picker |
| end_date | symbol | | end date for the date picker picker |

### fae_prefix(f, attribute, options)

*attributes only*

| option | type | default | description |
|-|-|-|-|-|
| prefix | string | | **(required)** string to appear in prefix box |
| icon | boolean | false | determines whether or not to display prefix icon |

### fae_suffix(f, attribute, options)

*attributes only*

| option | type | default | description |
|-|-|-|-|-|
| suffix | string | | **(required)** string to appear in suffix box |
| icon | boolean | false | determines whether or not to display prefix icon |

### fae_video_url(f, attribute, options)

*attributes only*

