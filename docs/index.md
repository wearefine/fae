# Usage

This doc needs to be structured to talk about...

- installation (yes again)
- generators
- models
	- Fae::Concerns::Models::Base
	- fae_display_field
- controllers
  - set_class_variables
  - build_assets
- form helpers (intro and link to helpers index)
	- slugs
- view helpers (intro and link to helpers index)
- pages
- overridding files



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
This helper will place a nested form partial in your view, you still need to build the image in your controller
The method takes the form object and the object that attaches to the Image relationship. The following optional params are available:

*<em>image_name</em>: the action image relationships name, defaults to :image
*<em>image_label</em>: defaults to the image_name
*<em>alt_label</em>: defaults to "#{image_label} alt text"
*<em>omit</em>: an array containing :caption and/or :alt, defaults to [:caption]
*<em>show_thumb</em>: defaults to false
*<em>required</em>: defaults to false
*<em>helper_text</em>: defaults to ""
*<em>alt_helper_text</em>: defaults to ""
*<em>caption_helper_text</em>: defaults to ""

```ruby
  fae_image_form f, @item
```
![Alt text](http://www.afinesite.com/fae/documentation/image_form.png')

####fae_date_format
The fae_date_format method takes a Date/DateTime object and an optional timezone string as its second parameter. It simply displays dates in a uniform way accross all implementations.

###Fae Partials

####_index_header.html.erb

* required variables
  * title: <em>string</em>
* optional variables
  * new_button: <em>boolean</em>
  * button_text: <em>string</em>

####_form_buttons.html.erb

* required variables
  * f: <em>form builder</em>
* optional variables
  * item: <em>instance variable for object to be deleted</em>
