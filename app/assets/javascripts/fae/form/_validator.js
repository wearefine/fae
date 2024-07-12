/* global Fae, judge, FCH */

/**
 * Fae form validator
 * @namespace form.validator
 * @memberof form
 */
Fae.form.validator = {
  is_valid: '',
  validations_called: 0,
  validations_returned: 0,
  validation_test_count: 0,
  invalidFields: [],

  init: function () {
    // validate all forms except the login form
    if ($('form').not('#login_form').length) {
      this.password_confirmation_validation.init();
      this.passwordPresenceConditional();
      this.bindValidationEvents();
      this.formValidate();
      this.length_counter.init();
      this.checkForSsrImageAndFileErrors();
    }
  },

  /**
   * Validate the entire form on submit and stop it if the form is invalid
   */
  formValidate: function ($scope) {
    var _this = this;

    if (typeof $scope === 'undefined') {
      $scope = FCH.$document;
    }
    $scope.on('submit', 'form:not([data-remote=true])', function (e) {
      var $this = $(this);

      if ($this.data('passed_validation') !== 'true') {
        // pause form submission
        e.preventDefault();

        // set defaults
        _this.is_valid = true;
        _this.validations_called = 0;
        _this.validations_returned = 0;
        _this.validation_test_count = 0;

        // Scope the data-validation only to the form submitted
        $('[data-validate]', $this).each(function () {
          if ($(this).data('validate').length) {
            _this.validations_called++;
            _this._judgeIt($(this));
          }
        });

        // Catch visible errors for image/file inputs hitting the fae config file size limiter
        $('.input.file', $this).each(function () {
          if ($(this).hasClass('field_with_errors')) {
            _this.is_valid = false;
          }
        });

        _this.testValidation($this, $scope);

      } else if (_this._preventFormSaveDueToNestedForm()) {
        // nested form has unsaved changes and user cancelled form submission
        e.preventDefault();
        
      } else {
        // form is valid and can submit so set saving indication
        _this._setSavingIndicator();
      }
    });
  },

  /**
   * Tests a forms validation after all validation checks have responded
   * Polls validations responses every 50ms to allow uniqueness AJAX calls to complete
   */
  testValidation: function ($this, $scope) {
    var _this = this;
    _this.validation_test_count++;

    setTimeout(function () {
      // if all the validation checks have returned a response
      if (_this.validations_called === _this.validations_returned) {
        if (_this.is_valid) {
          // if form is valid, submit it
          $this.data('passed_validation', 'true');

          $this.submit();
        } else {
          // otherwise scroll to the top to display alerts (unless in a nested form scope)
          Fae.navigation.language.checkForHiddenErrors();
          if (typeof $scope === 'undefined') {
            FCH.smoothScroll($('#js-main-header'), 500, 100, 0);
          }

          // display error messages grouped at top of form with jump links to invalid fields
          _this._buildErrorLinks($scope);

          if ($('.field_with_errors').length) {
            $('.errors-bar-wrapper').slideDown('fast');
          }
        }
      } else {
        // check again if it hasn't run more than 50 times
        // (to prevent against infinite loop)
        if (_this.validation_test_count < 50) {
          _this.testValidation($this);
        }
      }
    }, 50);
  },

  /**
   * Bind validation events based on input type
   */
  bindValidationEvents: function ($scope) {
    var _this = this;

    if (typeof $scope === 'undefined') {
      $scope = $('body');
    }

    $scope.find('[data-validate]').each(function () {
      var $this = $(this);

      if ($this.data('validate').length) {
        if ($this.is('input:not(.hasDatepicker), textarea')) {
          // normal inputs validate on blur
          $this.blur(function () {
            _this._judgeIt($this);
          });
        } else if ($this.hasClass('hasDatepicker')) {
          // date pickers need a little delay
          $this.blur(function () {
            setTimeout(function () {
              _this._judgeIt($this);
            }, 500);
          });
        } else if ($this.is('select')) {
          // selects validate on change
          $this.change(function () {
            _this._judgeIt($this);
          });
        }
      }
    });
  },

  /**
   * Sent indicator to let the user know the form is saving
   * @protected
   */
  _setSavingIndicator: function () {
    var $saveButton = $('.js-content-header').find('input[type="submit"]');
    $saveButton.addClass('saving').val('Saving...');
  },

  /**
   * Detect if a nested form has content and alert user
   * @protected
   */
  _preventFormSaveDueToNestedForm: function () {
    let preventSave = false;
    const $nestedFormWrapper = $('.js-addedit-form-wrapper:visible');
    // exit if no nested objects
    if ($nestedFormWrapper.length === 0) return false;

    const $form = $nestedFormWrapper.find('form');

    // get all form values without hidden fields. this omits utf encoding, csrf token, and parent item id fields
    const formValues = $form.find(':input:not(:hidden)').serializeArray();

    // detect if any fields have content
    const formHasContent = formValues.some((item) => item.value !== '');

    if (formHasContent) {
      const formLabel = $nestedFormWrapper.siblings('h2').text();
      // set to true if user decides not to continue
      preventSave = !window.confirm(
        `${formLabel} has unsaved changes! To return to your draft, click “Cancel.” To proceed without saving, click “OK.”`
      );

      if (preventSave) {
        FCH.smoothScroll($nestedFormWrapper, 500, 100, -100);
      }
    }

    return preventSave;
  },

  // check for server side errors for images/files and display error bar with jump links on form re-render
  checkForSsrImageAndFileErrors: function () {
    const _this = this;
    let imageErrorFound = false;

    $('.input.file').each(function () {
      $assetInput = $(this);
      if ($assetInput.hasClass('field_with_errors')) {
        const errorMessage = $assetInput.find('.error').text();
        _this._addInvalidField($assetInput, [errorMessage]);
        imageErrorFound = true;
      }
    });

    if (imageErrorFound) {
      this._buildErrorLinks();
      $('.errors-bar-wrapper').slideDown('fast');
    }
  },

  /**
   * Initialize Judge on a field
   * @protected
   * @param  {jQuery} $input - field to be validated
   */
  _judgeIt: function ($input) {
    var _this = this;

    judge.validate($input[0], {
      valid: function () {
        _this.validations_returned++;
        _this._createSuccessClass($input);
        _this._clearInvalidField($input);
      },
      invalid: function (input, messages) {
        _this.validations_returned++;
        messages = _this._removeIgnoredErrors(messages);
        if (messages.length) {
          _this.is_valid = false;
          _this._createOrReplaceError($input, messages);
          _this._addInvalidField($input, messages);
        }
      },
    });
  },

  /**
   * Add error to invalid fields array if it doesn't already exist
   * @protected
   * @param  {jQuery} $input - field to check if exists
   */
  _addInvalidField: function ($input, messages) {
    const foundIndex = this.invalidFields.findIndex((item) => {
      return item.$input[0] === $input[0];
    });
    if (foundIndex === -1) {
      this.invalidFields.push({
        $input: $input,
        messages: messages,
      });
    }
  },

  /**
   * Remove error from invalid fields array if exists
   * @protected
   * @param  {jQuery} $input - field to check if exists
   */
  _clearInvalidField: function ($input) {
    const foundIndex = this.invalidFields.findIndex((item) => {
      return item.$input[0] === $input[0];
    });
    if (foundIndex !== -1) {
      this.invalidFields.splice(foundIndex, 1);
    }
  },

  /**
   * Builds jump links for all invalid fields to display at top of form
   * @protected
   * @param  {jQuery} $scope - form scope
   */

  _buildErrorLinks: function ($scope) {
    const $header = $('.js-content-header');
    const headerHeight = $header[0].getBoundingClientRect().height;

    if (typeof $scope === 'undefined') {
      $scope = $('body');
    }

    // get all fields with non-empty validations
    const fieldsWithValidation = Array.from(
      $scope.find('[data-validate*="{"]')
    );

    // sort invalid fields to match ordering of fields within form
    this.invalidFields.sort((a, b) => {
      return (
        fieldsWithValidation.indexOf(a.$input[0]) -
        fieldsWithValidation.indexOf(b.$input[0])
      );
    });

    // generate error links
    const $errorLinks = this.invalidFields.map((field) => {
      const $wrapper = field.$input.parents('div.input');
      let label = $wrapper.find('.label_inner').text();

      // build clean label with name of field and error message
      label = `${label.replace('*', '')} - ${field.messages.join(', ')}`;

      // build jump link
      let $errorLink = $('<a/>', {
        class: 'error-jump-link',
        href: `#`,
        html: label,
      });

      // smooth scroll invalid field right below header
      $errorLink.click((e) => {
        e.preventDefault;
        FCH.smoothScroll($wrapper, 500, 100, headerHeight * -1);
      });
      return $errorLink;
    });

    // append all links to error bar in form_header partial
    $('.errors-bar').empty().append($errorLinks);
  },

  /**
   * Strips out ignored error messages
   * @protected
   * @param  messages - array of error messages from Judge
   */
  _removeIgnoredErrors: function (messages) {
    // Ignored error messages from Judge:
    // 'Judge validation for Release#name not allowed'
    // 'Slug Request error: 0'
    var ignored_error_substrings = ['Judge validation', 'Request error'];

    // loop through messages
    for (var i = 0; i < messages.length; i++) {
      // loop through ignored errors
      for (var j = 0; j < ignored_error_substrings.length; j++) {
        // if the substring exists in the error message
        if (messages[i].indexOf(ignored_error_substrings[j]) > -1) {
          // log it in the console and remove message
          window.console && console.log('Ignoring error: ', messages[i]);
          messages.splice(i, 1);
          break;
        }
      }
    }

    return messages;
  },

  /**
   * Adds and removes the appropriate classes to display the success styles
   * @protected
   * @param {jQuery} $input - Input field (can be a chosen object)
   */
  _createSuccessClass: function ($input) {
    var $styled_input = this._setTargetInput($input);
    $styled_input.addClass('valid').removeClass('invalid');

    $input
      .parent()
      .removeClass('field_with_errors')
      .children('.error')
      .remove();
  },

  /**
   * Adds and removes the appropriate classes to display the error styles
   * @protected
   * @param {jQuery} $input - Input field
   * @param {Array} messages - Error messages to display
   */
  _createOrReplaceError: function ($input, messages) {
    var $styled_input = this._setTargetInput($input);
    $styled_input.addClass('invalid').removeClass('valid');

    var $wrapper = $input.closest('.input');
    if ($wrapper.children('.error').length) {
      $wrapper.children('.error').text(messages.join(', '));
    } else {
      $wrapper
        .addClass('field_with_errors')
        .append("<span class='error'>" + messages.join(', ') + '</span>');
    }
  },

  /**
   * A DRY method for setting the element that should take the .valid or .invalid style
   * @protected
   * @param {jQuery} $input - Input field for a chosen object
   * @return {jQuery} The chosen container
   */
  _setTargetInput: function ($input) {
    var $styled_input = $input;

    // If field is a chosen input
    if ($input.next('.chosen-container').length) {
      if ($input.next('.chosen-container').find('.chosen-single').length) {
        $styled_input = $input.next('.chosen-container').find('.chosen-single');
      } else if (
        $input.next('.chosen-container').find('.chosen-choices').length
      ) {
        $styled_input = $input
          .next('.chosen-container')
          .find('.chosen-choices');
      }
    } else if ($input.hasClass('mde-enabled')) {
      $styled_input = $input.siblings('.editor-toolbar, .CodeMirror-wrap');
    }

    return $styled_input;
  },

  /**
   * Removes a field's Judge validation
   * @param {jQuery} $field - Input fields
   * @param {String} kind - Type of validation (e.g. 'presence' or 'confirmation')
   */
  stripValidation: function ($field, kind) {
    var validations = $field.data('validate');

    for (var i = 0; i < validations.length; i++) {
      // validation items can be strings or JSON objects
      // let's convert the strings to JSON so we're dealing with consistent types
      if (
        typeof validations[i] == 'string' ||
        validations[i] instanceof String
      ) {
        validations[i] = JSON.parse(validations[i]);
      }

      // if the kind matches, remove it from the array
      if (validations[i]['kind'] === kind) {
        validations.splice(i, 1);
        i--;
      } else {
        // otherwise convert JSON back to a string
        validations[i] = JSON.stringify(validations[i]);
      }
    }
    $field.data('validate', '[' + validations + ']');
  },

  /**
   * Password Confirmation Validation
   * @description Judge validates confirmation on the original field. This is a hack to remove Judge's validation and add it to the confirmation field
   * @namespace
   * @memberof! validator
   */
  password_confirmation_validation: {
    init: function () {
      var _this = this;

      _this.$password_field = $('#user_password');
      _this.$password_confirmation_field = $('#user_password_confirmation');

      if (_this.$password_confirmation_field.length) {
        Fae.form.validator.stripValidation(
          _this.$password_field,
          'confirmation'
        );
        _this.addCustomValidation();
      }
      // See https://github.com/wearefine/fae/issues/409
      // This was preventing the functionality of a checkbox field
      // on the user form.
      _this.$password_field.data('validate', '');
    },

    /**
     * Validate password on blur and form submit; halt form execution if invalid
     */
    addCustomValidation: function () {
      var _this = this;

      /**
       * Displays success or error depending on password validation
       * @private
       * @param {Object} self - The password_confirmation_validation object
       * @see {@link validator.password_confirmation_validation.addCustomValidation addCustomValidation}
       */
      function validateConfirmation() {
        var validator = Fae.form.validator;

        if (
          _this.$password_field.val() ===
          _this.$password_confirmation_field.val()
        ) {
          validator._createSuccessClass(_this.$password_confirmation_field);
        } else {
          var message = ['must match Password'];
          validator.is_valid = false;
          validator._createOrReplaceError(
            _this.$password_confirmation_field,
            message
          );
        }
      }

      this.$password_confirmation_field.on('blur', validateConfirmation);

      $('form').on('submit', function (ev) {
        _this.is_valid = true;
        validateConfirmation();

        if (!_this.is_valid) {
          ev.preventDefault();
        }
      });
    },
  },

  /**
   * Judge always read the `on: :create` validations, so we need to strip the password presence validation on the user edit form
   */
  passwordPresenceConditional: function () {
    var $edit_user_password = $('.edit_user #user_password');
    if ($edit_user_password.length) {
      this.stripValidation($edit_user_password, 'presence');
    }
  },

  /**
   * Length Counter
   * @namespace
   * @memberof! validator
   */
  length_counter: {
    init: function () {
      this.findLengthValidations();
    },

    /**
     * Add counter text to fields that validate based on character counts
     */
    findLengthValidations: function () {
      var _this = this;

      $('[data-validate]').each(function () {
        var $this = $(this);

        if ($this.data('validate').length) {
          var validations = $this.data('validate');

          $.grep(validations, function (item) {
            if (item.kind === 'length') {
              $this.data('length-max', item.options.maximum);
              _this._setupCounter($this);
            }
          });
        }
      });
    },

    /**
     * Sets up the counter
     * @access protected
     * @param {jQuery} $elem - Input field being counted
     */
    _setupCounter: function ($elem) {
      var _this = this;

      _this._createCounterDiv($elem);
      _this.updateCounter($elem);

      $elem
        .keyup(function () {
          _this.updateCounter($elem);
        })
        .keypress(function (e) {
          if (_this._charactersLeft($elem) <= 0) {
            if (e.keyCode !== 8 && e.keyCode !== 46) {
              e.preventDefault();
            }
          }
        });
    },

    /**
     * Creates counter HTML
     * @protected
     * @param {jQuery} $elem - Input field to evaluate
     */
    _createCounterDiv: function ($elem) {
      if ($elem.siblings('.counter').length === 0) {
        var text = 'Maximum Characters: ' + $elem.data('length-max');
        text += " / <span class='characters-left'></span>";

        var $counter_div = $('<div />', {
          class: 'counter',
          html: '<p>' + text + '</p>',
        });

        $elem.parent().append($counter_div);
      }
    },

    /**
     * Updates the counter count and class
     * @param {jQuery} $elem - Input field to evaluate
     */
    updateCounter: function ($elem) {
      var $count_span = $elem.siblings('.counter').find('.characters-left');
      if ($count_span.length) {
        var current = this._charactersLeft($elem);
        var text;

        if (current >= 0) {
          text = 'Characters Left: ';
          $count_span.removeClass('overCount');
        } else {
          text = 'Characters Over: ';
          $count_span.addClass('overCount');
        }

        $count_span.text(text + Math.abs(current));
      }
    },

    /**
     * Calculate character's left
     * @protected
     * @param {jQuery} $elem - Input field being counted
     * @return {integer} The number of characters left
     */
    _charactersLeft: function ($elem) {
      var input_value = $elem.val();
      var current = $elem.data('length-max') - input_value.length;
      // Rails counts a newline as two characters, so let's make up for it here
      current -= (input_value.match(/\n/g) || []).length;

      return current;
    },
  },
};
