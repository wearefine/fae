var Validator = {

  init: function () {
    this.validate();
    this.form_validate();
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
        e.preventDefault();
      }
    });
  },

  // validate individual judge elements on the blur event
  validate: function () {
    var self = this;
    $('[data-validate]').each(function () {
      var $validation_element = $event_trigger = $(this);
      if ($validation_element.data('validate').length) {
        if (self.is_chosen($validation_element)) {
          $event_trigger = self.chosen_input($validation_element);
        }
        $event_trigger.blur(function () {
          self.judge_it($validation_element);
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
  }


};
