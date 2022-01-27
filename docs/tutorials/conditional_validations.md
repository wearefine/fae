# Conditional Validation

In order to add validation that is conditional you must configure FAE and [Judge](https://github.com/joecorcoran/judge#writing-your-own-eachvalidator) by using custom `eachValidators`.

Once you've done this you can require a field based on the value of another. For example: if you only want to require a `slug` field if you check `detail page` checkbox on a project object.

* [Add Validator](#add-validator)
* [Fae SCSS](#fae-scss)
* [Fae JS](#fae-js)

---

## Add Validator

To start, add a validator in the the `app/validator/` with a file name like `detail_page_validator.rb`

```ruby
class DetailPageValidator < ActiveModel::EachValidator
  uses_messages :no_detail_page

  def validate_each(record, attribute, value)
    if record.detail_page && value.blank?
      record.errors.add(attribute, :no_detail_page)
    end
  end
end
```

### Update Model

Next, update your model to use the `detail_page` validation:

```ruby
class Project < ActiveRecord::Base
  validates :name, presence: true
  validates :slug, detail_page: true
end
```

In your form view nest the optional fields, and add some classes for js and sass. In this case we are looking at the project form.

```ruby
= simple_form_for([:admin, @item]) do |f|
  ...

  .content
    = fae_input f, :name
    = fae_input f, :detail_page, helper_text: "This project has a detail page and should display on the Work category page(s)"
    .js-optional-fields class=("#{ 'hidden' unless (params[:action] == 'edit' && @item.detail_page?) }")
      = fae_input f, :slug, label_html: { class: 'is_required_and_hidden'}
```

### Update Judge

Update Judge so that judge loads your custom `EachValidtor` on the FE in a file name like 'validator.js'

```javascript
var Validator = {

    init: function() {
      judge.eachValidators.detail_page = function(options, messages) {
        var errorMessages = [];
        // 'this' refers to the form element
        is_checked = $('#project_detail_page').prop("checked") === true;
        if ( is_checked && (this.value === undefined || this.value === "")) {
          errorMessages.push(messages.no_detail_page);
        }
        return new judge.Validation(errorMessages);
      };
    }
};
```

and in FAE.js require the file above at the top
```javascript
//= require validator
```

## Fae SCSS

In `fae.scss` add in some styles for the `hidden` and `is_required_and_hidden` classes.

```sass
// Do Not Delete this page! FAE depends on it in order to set its highlight color.
$c-custom-highlight: #e6253c;

.hidden {
  display: none;
}

label.is_required_and_hidden {
  &:before {
    content: '* ';
    color: $c-custom-highlight;
  }
}
```

## Fae JS

In `fae.js` add in code for the toggling of the button detail page button to show and hide your conditionally required fields. Be sure to require validator js at the top, and init the Validator from the above js in the init or ready function.

```javascript
//= require validator

var AcmeAdmin = {

  init: function() {
    Validator.init();
    var _this = this;
    if ( $('body.projects').length && $('body.projects.index').length === 0 ) {
      _this.check_for_detail_page("#project_detail_page");
      _this.project_edit_listener();
    }
  },

  project_edit_listener: function() {
    var _this = this;
    $("#project_detail_page").click(function(){
      _this.check_for_detail_page($(this));
    });
  },

  check_for_detail_page: function(field) {
    if ($(field).is(':checked')) {
      $('.js-optional-fields').removeClass('hidden');
    } else {
      $('.js-optional-fields').not('hidden').addClass('hidden');
      $('.js-optional-fields').find('input').val('');
    }
  }

};

$(document).ready(function() {
  AcmeAdmin.init();
});
```
