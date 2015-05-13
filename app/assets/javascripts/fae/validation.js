var Validator = {

  init: function () {
    this.password_confirmation_validation.init();
    this.password_presence_conditional();
    this.validate();
    this.form_validate();
    this.length_counter.init();
  },

  vars: {
    IS_VALID: ''
  },

  // validate the entire form on submit and stop it if the form is invalid
  form_validate: function () {
    var self = this;
    $('form').on('submit', function (e) {
      self.vars.IS_VALID = true;
      $('[data-validate]').each(function () {
        if ($(this).data('validate').length) {
          self.judge_it($(this));
        }
      });
      if (self.vars.IS_VALID === false) {
        LanguageNav.check_for_hidden_errors();
        Admin.scroll_to($('span.error').first());
        e.preventDefault();
      }
    });
  },

  // validate individual judge elements on the blur event
  validate: function () {
    var self = this;
    $('[data-validate]').each(function () {
      var $validation_element = $(this);
      var $event_trigger = $validation_element;
      if ($validation_element.data('validate').length) {
        if (self.is_chosen($validation_element)) {
          $event_trigger = self.chosen_input($validation_element);
        }
        $event_trigger.blur(function () {
          if (!$(this).hasClass("hasDatepicker")) {
            self.judge_it($validation_element);
          } else {
            setTimeout(function(){ self.judge_it($validation_element); }, 500);
          }
        });
      }
    });
  },

  // 'private functions'

  // main judge call
  judge_it: function ($input) {
    var self = this;
    judge.validate($input[0], {
      valid: function () {
        self.create_success_class($input);
      },
      invalid: function (input, messages) {
        self.vars.IS_VALID = false;
        self.label_named_message($input, messages);
        self.create_or_replace_error($input, messages);
      }
    });
  },


  // sets the input element that is focused on chosen elements
  chosen_input: function ($input) {
    return $input.next('.chosen-container').find('input');
  },

  // returns a BOOL based on if the input is a chosen input
  is_chosen: function ($input) {
    return $input.next('.chosen-container').length;
  },



  label_named_message: function (elm, messages) {
    var i, siblings, index;
    for (i = messages.length - 1; i >= 0; i--) {
      siblings = elm.siblings('label');
      if (siblings.get(0).childNodes[0].nodeName === "ABBR") { index = 1; }
      index = index || 0;
      messages[i] = siblings.get(0).childNodes[index].nodeValue + " " + messages[i];
    }
  },



  // adds and removes the appropriate classes to display the success styles
  create_success_class: function ($input) {
    var $styled_input = this.set_chosen_input($input);
    $styled_input.addClass('valid').removeClass('invalid');

    $input.parent().removeClass('field_with_errors').children('.error').remove();
  },

  // adds and removes the appropriate classes to display the error styles
  create_or_replace_error: function ($input, messages) {
    var $styled_input = this.set_chosen_input($input);
    $styled_input.addClass('invalid').removeClass('valid');

    if ($input.parent('.input').children('.error').length) {
      $input.parent('.input').children('.error').text(messages.join(','));
    } else {
      $input.parent('.input').addClass('field_with_errors').append("<span class='error'>" + messages.join(',') + "</span>");
    }
  },

  // a DRY method for setting the element that should take the .valid or .invalid style
  set_chosen_input: function ($input) {
    var $styled_input = $input;
    if (this.is_chosen($input)) {
      if ($input.next('.chosen-container').find('.chosen-single').length) {
        $styled_input = $input.next('.chosen-container').find('.chosen-single');
      } else if ($input.next('.chosen-container').find('.chosen-choices').length) {
        $styled_input = $input.next('.chosen-container').find('.chosen-choices');
      }
    }

    return $styled_input;
  },

  // strips a fields Judge validation
  // $field: input fields as a jQuery object
  // kind: the kind of validation (e.g. 'presence' or 'confirmation')
  strip_validation: function($field, kind) {
    var validations = $field.data('validate');
    for (var i = 0; i < validations.length; i++) {
      // validation items can be strings or JSON objects
      // let's convert the strings to JSON so we're dealing with consistent types
      if (typeof validations[i] == 'string' || validations[i] instanceof String) {
        validations[i] = JSON.parse(validations[i]);
      }

      // if the kind matches, remove it from the array
      if (validations[i]['kind'] === kind) {
        validations.splice(i, 1);
      }

      // convert JSON back to a string
      validations[i] = JSON.stringify(validations[i]);
    }
    $field.attr('data-validate', '[' + validations + ']');
  },

  // Judge validates confirmation on the original field
  // this is a hack to remove Judge's validation and add it to the confirmation field
  password_confirmation_validation: {
    $password_field: null,
    $password_confirmation_field: null,

    init: function() {
      var self = this;

      self.$password_field = $('#user_password');
      self.$password_confirmation_field = $('#user_password_confirmation');

      if (self.$password_confirmation_field.length) {
        Validator.strip_validation(self.$password_field, 'confirmation');
        self.add_custom_validation();
      }
    },

    add_custom_validation: function() {
      var self = this;
      self.$password_confirmation_field.on('blur', function() {
        self.validate_confirmation(self);
      });
      $('form').on('submit', function(ev) {
        Validator.vars.IS_VALID = true;
        self.validate_confirmation(self);
        if (!Validator.vars.IS_VALID) {
          ev.preventDefault();
        }
      });
    },

    validate_confirmation: function(self) {
      if (self.$password_field.val() == self.$password_confirmation_field.val()) {
        Validator.create_success_class(self.$password_confirmation_field);
      } else {
        var message = ['must match Password'];
        Validator.vars.IS_VALID = false;
        Validator.label_named_message(self.$password_confirmation_field, message);
        Validator.create_or_replace_error(self.$password_confirmation_field, message);
      }
    }
  },

  // Judge always read the `on: :create` validations,
  // so we need to strip the password presence validation
  // on the user edit form
  password_presence_conditional: function() {
    var $edit_user_password = $('.edit_user #user_password');
    if ($edit_user_password.length) {
      this.strip_validation($edit_user_password, 'presence');
    }
  },

  length_counter: {

    init: function(){
      this.find_length_validations();
    },

    find_length_validations: function() {
      var self = this;
      $('[data-validate]').each(function () {
        var $this = $(this);
        if ($this.data('validate').length ) {
          var validations = $this.data('validate');
          $.grep(validations, function(item){
            if (item.kind == 'length'){
              var max = item.options.maximum;
              self.set_counter($this, max);
            }
          });
        }
      });
    },

    set_counter: function($elem, max, current) {
      current = current || 0 + (max - $elem.val().length);

      var text = this._create_counter_text($elem, max, current);

      if ($elem.siblings('.counter').length) {
        $elem.siblings('.counter').remove();
        this.create_counter_elem($elem, max, current, text);
      } else {
        this.create_counter_elem($elem, max, current, text);
        this.add_counter_listener($elem, max);
      }
    },

    _create_counter_text: function($elem, max, current) {
      var prep = "Maximum Characters: " + max;
      if (current > 0 || $elem.val().length > 0) {
        prep += " / <span class='characters-left'>Characters Left: " + current + "</span>";
      }
      return prep;
    },

    create_counter_elem: function($elem, max, current, text){
      $( "<div class='counter' data-max="+max+" data-current="+ current +"><p>" + text + "</p></div>" ).insertAfter( $elem );
      if (current <= 0 || $elem.val().length >= 100){
        $elem.siblings('.counter').children('p').children('.characters-left').addClass('overCount');
      }
    },

    add_counter_listener: function($elem, max) {
      var self = this;
      $elem.keyup(function() {
        var current = (max - ($elem.val().length));
        self.set_counter($elem, max, current);
      });
      $elem.keypress(function(e) {
        var current = (max - $elem.val().length);
        if (current <= 0) {
          if (e.keyCode !== 8 || e.keyCode !== 46) {
            e.preventDefault();
          }
        }
      });
    }
  },


};
