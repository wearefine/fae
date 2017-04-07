# Form Helpers

Generated forms start you off on a good place to manage the object's content, but chances are you'll want to customize them and add more fields as you data model evolves. Fae provides a number of form helpers to help you leverage Fae's built in features will allowing customization when needed.

Form helpers in Fae use the [simple_form](https://github.com/plataformatec/simple_form) gem as it's base. In most cases options that simple_form accepts can be passed into these helpers directly. The reason why we've established these helpers it to allow for customized options. They also provide a method to directly hook into Fae, so we can push out features and bugfixes.

* [Format](#format)
* [Fae Input](#fae-input)
* [Fae Association](#fae-association)
* [Fae Checkbox](#fae-checkbox)
* [Fae Radio](#fae-radio)
* [Fae Pulldown](#fae-pulldown)
* [Fae Multiselect](#fae-multiselect)
* [Fae Grouped Select](#fae-grouped-select)
* [Fae Datepicker](#fae-datepicker)
* [Fae Daterangepicker](#fae-daterangepicker)
* [Fae Prefix](#fae-prefix)
* [Fae Suffix](#fae-suffix)
* [Fae Video URL](#fae-video-url)

---

## Format

All form helpers are in the following format:

```ruby
fae_method_name(f, attribute, options)
```

| argument | description |
| -------- | ----------- |
| f | **(required)** The variable simple_form passes through in its block. The actual variable can vary based on how you setup the view, but `f` is the generated default. |
| attribute | **(required)** The attribute the form element is displaying. It's recommended you use symbols over strings. |
| options | An optional hash of options to customize the form element. |

### Global Options

| option | type | default | description |
| ------ | ---- | ------- | ----------- |
| label | string | attribute.titleize | the form label |
| helper_text | string | | helper text that appears under label |
| hint | string | | text that appears in a hint modal |
| dark_hint | string | | **warning: this option will be depreciated in v2.0** text that appears in a dark color scheme (`hint` will override `dark_hint` if simultaneously supplied) |
| markdown | boolean | false | adds markdown GUI toolbar |
| markdown_supported | boolean | false | displays support text and hint for markdown |
| input_class | string | | a class to add to the input element |
| wrapper_class | string | | a class to add to the wrapper element |
| validate | boolean | true | triggers `judge` to validate element |

## Fae Input

```ruby
fae_input
```

*attributes only*

fae_input is the basic input method derived from simple_form's f.input. What it displays will depend on the column type of the attribute. See [simple_form's documentationn](https://github.com/plataformatec/simple_form#available-input-types-and-defaults-for-each-column-type) to learn more.

**Examples**

An input[type=text] with an added wrapper_class and helper_text:
```ruby
fae_input f, :first_name, wrapper_class: 'special_wrapper', helper_text: 'No more than 50 characters'
```

A text area with Fae's built-in markdown hint:
```ruby
fae_input f, :description, markdown_supported: true
```

## Fae Association

```ruby
fae_association
```

*associations only*

fae_association is directly derived from simple_form's f.association. Again, the element it renders depends on the association type.

| option | type | default | description |
| ------ | ---- | ------- | ----------- |
| collection | array or AR:Relation | AssociationClass.all | an array or ActiveRecord object of items to populate the element |

**Examples**

A dropdown listing active people
```ruby
fae_association f, :people, collection: Person.active
```

## Fae Checkbox

```ruby
fae_checkbox
```

![Checkbox](https://raw.githubusercontent.com/wearefine/fae/master/docs/images/checkbox.png)

| option | type | default | description |
| ------ | ---- | ------- | ----------- |
| type | 'stacked' or 'inline' | stacked | determines how multiple checkboxes are displayed |

**Examples**

A single attribute checkbox
```ruby
fae_checkbox f, :active
```

Inline has_many collection of checkboxes
```ruby
fae_checkbox f, :promos, type: 'inline', collection: Promo.live
```

## Fae Radio

```ruby
fae_radio
```

![Radio](https://raw.githubusercontent.com/wearefine/fae/master/docs/images/radio.png)

| option | type | default | description |
| ------ | ---- | ------- | ----------- |
| type | 'stacked' or 'inline' | stacked | determines how multiple checkboxes are displayed |

**Examples**

A single attribute radio
```ruby
fae_radio f, :active, type: 'inline'
```

A belongs_to association
```ruby
fae_radio f, :wine
```

## Fae Pulldown

```ruby
fae_pulldown
```

![Pulldown](https://raw.githubusercontent.com/wearefine/fae/master/docs/images/pulldown.gif)

| option | type | default | description |
| ------ | ---- | ------- | ----------- |
| collection | array or AR:Relation | AssociationClass.all | an array or ActiveRecord object of items to populate the element |
| size | 'long' or 'short' | long | determines the size of the pulldown |
| search | boolean | search is displayed with more than 10 items | determines whether or not to show the search bar |

**Examples**

A short pulldown of a belongs_to association
```ruby
fae_pulldown f, :wine, size: 'short', collection: Wine.order(:name)
```

With search:

![Pulldown with search](https://raw.githubusercontent.com/wearefine/fae/master/docs/images/pulldown_search.gif)

## Fae Multiselect

```ruby
fae_multiselect
```

![Multiselect](https://raw.githubusercontent.com/wearefine/fae/master/docs/images/multiselect.gif)

*associations only*

| option | type | default | description |
| ------ | ---- | ------- | ----------- |
| two_pane | boolean | false | By default this will display a chosen style multiselect. Setting this to true will display the 'two pane' style. |

**Examples**

A chosen style multiselect with custom label_method
```ruby
fae_multiselect f, :acclaims, label_method: :publication
```

A two pane style multiselect
```ruby
fae_multiselect f, :selling_points, two_pane: true
```

![Multiselect](https://raw.githubusercontent.com/wearefine/fae/master/docs/images/two_pane_multiselect.gif)

## Fae Grouped Select

```ruby
fae_grouped_select
```

| option | type | default | description |
| ------ | ---- | ------- | ----------- |
| collection | array or AR:Relation | AssociationClass.all | an array or ActiveRecord object of items to populate the element |
| groups | array of strings | | must be used with labels |
| labels | array of strings | | must be used with groups |

## Fae Datepicker

```ruby
fae_datepicker
```

![Datepicker](https://raw.githubusercontent.com/wearefine/fae/master/docs/images/datepicker.gif)

*attributes only*

**Examples**

```ruby
fae_datepicker f, :release_date
```

## Fae Daterangepicker

```ruby
fae_daterangepicker
```

![Daterange picker](https://raw.githubusercontent.com/wearefine/fae/master/docs/images/daterange_picker.gif)

*attributes only*

The daterangepicker is a little different: instead of a single attribute, it accepts an array of two attributes.

**Examples**

```ruby
fae_daterange f, [:start_date, :end_date], label: 'Start/End dates'
```

## Fae Prefix

```ruby
fae_prefix
```

![Prefix](https://raw.githubusercontent.com/wearefine/fae/master/docs/images/prefix.png)

*attributes only*

| option | type | default | description |
| ------ | ---- | ------- | ----------- |
| prefix | string | | **(required)** string will appear in prefix box |
| icon | boolean | false | determines whether or not to display prefix icon |

**Examples**

```ruby
fae_prefix f, :price, prefix: '$', placeholder: '50.00'
```

## Fae Suffix

```ruby
fae_suffix
```

![Suffix](https://raw.githubusercontent.com/wearefine/fae/master/docs/images/suffix.png)

*attributes only*

| option | type | default | description |
| ------ | ---- | ------- | ----------- |
| suffix | string | | **(required)** string will appear in suffix box |
| icon | boolean | false | determines whether or not to display prefix icon |

**Examples**

```ruby
fae_suffix f, :weight, suffix: 'lbs'
```

## Fae Video URL

```ruby
fae_video_url
```

![Video URL](https://raw.githubusercontent.com/wearefine/fae/master/docs/images/video_url.gif)

*attributes only*

This helper is a normal fae_input, but provides a custom helper and hint specific to extracting YouTube IDs.

**Examples**

```ruby
fae_video_url f, :video_url
```