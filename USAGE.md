##Usage

###Form Helper Methods

All FAE helper methods add the ability to use simpler syntax for input class and wrapper class - respectively <em>class</em> and <em>wrapper_class</em>

```ruby
  fae_input f, :state, wrapper_class: 'special_wrapper', class: 'special_input'
  fae_association f, :child, wrapper_class: 'unique_wrapper', class: 'unique_input'
```

####Prefix and suffix
The prefix and suffix helpers both have a required option of <em>prefix</em> and <em>suffix</em>, there is an optional <em>icon</em> option which takes a boolean and activates some preset icons if the prefix/suffix option is named correctly
```ruby
  fae_prefix f, :amount, prefix: '$'
```
![Alt text](http://www.afinesite.com/fae/documentation/fae_prefix.png')


```ruby
  fae_suffix f, :discount, suffix: '%'
```
![Alt text](http://www.afinesite.com/fae/documentation/fae_suffix.png')

####Radio and checkbox
The radio and checkbox helper allows for an option to align it vertically or horizontally, the default is vertical. It also works for associations with an optional 'collection' option that takes an array, multi-dimentional array, or ActiveRecord#Relation object as a value.
```ruby
  fae_radio f, :on_stage
```
![Alt text](http://www.afinesite.com/fae/documentation/fae_radio_stacked.png')

```ruby
  fae_checkbox f, :on_prod, type: 'inline'
```
![Alt text](http://www.afinesite.com/fae/documentation/fae_radio_inline.png')

####Pulldown
The pulldown helper adds a dropdown with a search field on your associations or model attributes. It takes a <em>size</em> option that accepts 'short' or 'long', 'long' is the default. This helper by default works on associations and inputs, if you want to use it on inputs you must specify a 'collection' as a multi-dimentional array or an ActiveRecord#Relation object as a value. The `search` option defaults to true, but is optional and takes a boolean.
```ruby
  fae_pulldown f, :varietal
```
![Alt text](http://www.afinesite.com/fae/documentation/fae_pulldown.png')

```ruby
  fae_pulldown f, :wine, size: 'short'
```
![Alt text](http://www.afinesite.com/fae/documentation/fae_pulldown_short.png')

####Multiselect
The multiselect helper takes an optional parameter of 'two_pane' which takes a Boolean. This method is restricted to ActiveRecord#Relation's.
```ruby
  fae_multiselect f, :selling_points, two_pane: true
```
![Alt text](http://www.afinesite.com/fae/documentation/fae_multiselect_two_pane.png')

```ruby
  fae_multiselect f, :acclaims, label_method: :publication
```
![Alt text](http://www.afinesite.com/fae/documentation/fae_multiselect.png')

####Grouped Select
The grouped_select helper takes either a `collection` option or the `labels` and `groups` options. The `labels` and `groups` options must be contain arrays of equal length.
```ruby
  states = {'Califonia' => ['Los Angeles', 'San Francisco'], 'Oregon' => ['Portland', 'Boring']}
  fae_grouped_select f, :city, collection: states %>
```

or

```ruby
  fae_grouped_select f, :city, labels: states.keys , groups: states.values
```
![Alt text](http://www.afinesite.com/fae/documentation/a')

####Datepicker
The datepicker helper simply displays a field with a calendar icon that applies a single calendar dropdown
```
  fae_datepicker f, :start_date
```
![Alt text](http://www.afinesite.com/fae/documentation/fae_datepicker.png')


####Daterange
The daterange helper sets up two fields that work together to form a date range. By default it applies to the `start_date` and `end_date` attribute, but this can be overridden by placing the appropriate attributes inside the start_date and end_date options.
```ruby
  fae_daterange f, :display_dates
```
```ruby
  fae_daterange f, :display_dates, start_date: :begin, end_date: :end
```
![Alt text](http://www.afinesite.com/fae/documentation/fae_daterange.png')

###Application Helper Methods

####attr_toggle
The attr_toggle helper method takes an AR object and an attribute. It then creates the html necessary for a working fae on/off toggle switch
```ruby
  attr_toggle item, :on_stage
```
![Alt text](http://www.afinesite.com/fae/documentation/attr_toggle.png')

####form_header
The form_header helper method creates an h1 tag in the format of "params[:action] name"

edit page input: `form_header @user` renders `<%= "<h1>Edit User</h1>" %>`

new page input: `form_header 'Special Releases'` renders `<%= "<h1>New Special Releases</h1>" %>`

####markdown_helper
The markdown_helper supplies a string of markdown helper information

####require_locals
The require_locals method is intended to be used at the beginning of any partial that pulls in a local variable from the page that renders it. It takes a Array of strings containing the variables that are required and the local_assigns view helper method

####image_form
The image_form helper method takes the form object and the object that attaches to the Image relationship. The following optional params are available:

*<em>image_name</em>: the action image relationships name, defaults to :image
*<em>image_label</em>: defaults to the image_name
*<em>alt_label</em>: defaults to "#{image_label} alt text"
*<em>omit</em>: an array containing :caption and/or :alt, defaults to [:caption]
*<em>show_thumb</em>: defaults to false

```ruby
  image_form f, @item
```
![Alt text](http://www.afinesite.com/fae/documentation/image_form.png')

####fae_date_format
The fae_date_format method takes a Date/DateTime object and an optional timezone string as its second parameter. It simply displays dates in a uniform way accross all implementations.