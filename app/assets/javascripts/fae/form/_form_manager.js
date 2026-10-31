/* global Fae */

/**
 * Fae form manager
 * @namespace form
 * @memberof Fae
 */
Fae.form.formManager = {

  $theForm:                 null,
  $managerForm:             null,
  savedFieldSettings:       null,
  mainContentClass:         'main-content',
  fmContainerClass:         'js-form-manager-container',
  formManagerFormClass:     'form-manager-form',
  launchManagerClass:       'js-launch-form-manager',
  cancelManagerClass:       'js-form-manager-cancel',
  saveAndCloseManagerClass: 'js-form-manager-submit',
  helperTextTextElClass:    'helper_text_text',
  maxLengthInputClass:      'max_length_input',
  // Used when the database doesn't report a column limit (via the input's maxlength attribute)
  inputMaxLengthCeiling:    255,
  textareaMaxLengthCeiling: 65535,
  infoAttr:                 'data-form-manager-info',
  languageAttr:             'data-language',
  requiredEl:               '<abbr title="required">*</abbr> ',
  containerManagerDataId:   'data-form-manager-id',
  ignoredFields: [
    'seo_title',
    'seo_description',
    'social_media_title',
    'social_media_description',
    'social_media_image'
  ],

  init: function(formSelector) {
    var _this      = this;
    formSelector   = formSelector || 'form:first';
    _this.$theForm = $(formSelector);

    // Draw initial label/helper overrides
    _this.setupAllFields(_this.$theForm);

    $('body').on('click', '.'+_this.launchManagerClass, function(e) {
      e.preventDefault();
      _this.$theForm = $(this).parents('form');
      _this._launchManager($(this));
    });

    $('body').on('click', '.'+_this.saveAndCloseManagerClass, function(e) {
      e.preventDefault();
      _this._saveAndCloseManager($(this));
    });

    $('body').on('click', '.'+_this.cancelManagerClass, function(e) {
      e.preventDefault();
      _this._closeManager($(this));
    });

  },

  setupAllFields: function($theForm) {
    _this = this;
    if ($theForm.length && $theForm.attr(_this.infoAttr)) {
      this.savedFieldSettings = JSON.parse($theForm.attr(_this.infoAttr));

      $.each(JSON.parse(this.savedFieldSettings.fields), function(i, fieldSettings) {
        _this._determineFieldSetup(fieldSettings);
      });
    }
  },

  _determineFieldSetup: function(fieldSettings) {
    var $container = $('[data-form-manager-id="'+fieldSettings.formManagerId+'"]');
    _this._setupField($container, fieldSettings.label, fieldSettings.helper);

    if ($container.hasClass('image')) {
      var $captionContainer = $('.' + fieldSettings.formManagerId + '_caption_container');
      var $altContainer = $('.' + fieldSettings.formManagerId + '_alt_container');

      if ($captionContainer) {
        var captionLabel = fieldSettings.label + ' Caption';
        _this._setupField($captionContainer, captionLabel, '');
      }
      if ($altContainer) {
        var altLabel = fieldSettings.label + ' Alt Text';
        _this._setupField($altContainer, altLabel, '');
      }
    }
  },

  _setupField: function($container, overriddenLabel, overriddenHelper) {
    var _this = this;
    if ($container.length) {
      var $label                 = $container.find('label:first');
      var $helperTextContainerEl = $container.find('h6');
      var $labelInner            = $label.find('.label_inner');
      var $labelTextEl           = $label;
      if ($labelInner.length) {
        $labelTextEl = $labelInner;
      }
      var $labelsCheckbox = $labelTextEl.find('input');

      var newLabelText = '';
      if ($container.hasClass('required') || $label.hasClass('required') || $labelInner.text().indexOf('*') !== -1) {
        newLabelText = _this.requiredEl;
      }

      newLabelText += overriddenLabel;
      $labelTextEl.html(newLabelText);

      if($labelsCheckbox.length) {
        $labelTextEl.append($labelsCheckbox);
      }

      // Don't mess with image alt text or caption helpers
      if ($container.attr('class').indexOf('alt_container') !== -1
          || $container.attr('class').indexOf('caption_container') !== -1
         ) {
        return;
      }

      // Just do the helper thing no matter what, aka allow empty
      $label.removeClass('has_no_helper_text');

      // Main form and nested form markup differs, deal with it
      if ($container.find('h6').length) {
        $label.find('.'+_this.helperTextTextElClass).text(overriddenHelper);
      } else {
        if ($helperTextContainerEl.length) {
          $helperTextContainerEl.find('.'+_this.helperTextTextElClass).text(overriddenHelper);
        } else {
          $helperTextContainerEl = $('<h6 />', {class: 'helper_text'}).append($('<span />', {class: 'helper_text_text', text: overriddenHelper}));
        }
        $label.append($helperTextContainerEl);
      }
    }
  },

  _launchManager: function() {
    var _this = this;

    // Show all language inputs so we can manage them
    _this.$theForm.find('['+_this.languageAttr+']').show();

    _this.$managerForm =
      $('<form />', {action: '#', class: _this.formManagerFormClass})
        .append($('<header />', {class: 'content-header js-content-header js-will-be-sticky'})
          .append($('<a />', {href: '#', text: 'Cancel', class: 'button '+_this.cancelManagerClass}))
          .append($('<a />', {href: '#', text: 'Submit', class: 'button js-form-manager-submit'}))
      );

    // Insert a bunch of inputs for label/helper text
    _this._gatherAndInjectManagerEls();

    $('.'+_this.fmContainerClass).append(_this.$managerForm);
    _this._revealManagerForm();

  },

  _gatherAndInjectManagerEls: function() {
    var _this = this;
    $(_this.$theForm.find('['+_this.containerManagerDataId+']')).each(function(i) {
      var $container    = $(this);

      if ($container.hasClass('hidden') || !_this._shouldDisplayInManager($container)) { return; }

      var $label        = $container.find('label:first');
      var $labelTextEl  = $label;
      var $labelInner   = $label.find('.label_inner');
      if ($labelInner.length) {
        $labelTextEl = $labelInner;
      }
      var $helperTextTextEl  = $label.find('.'+_this.helperTextTextElClass);
      var containerManagerId = $container.attr(_this.containerManagerDataId);
      var iDParts            = containerManagerId.split('_');
      iDParts.shift();
      var fMLabelText        = _this._titleize(iDParts.join(' '));
      var labelInputValue    = $labelTextEl.clone().children().remove().end().text().replace('*','').trim();
      var helperInputValue   = $helperTextTextEl.text();

      var $fmFieldContainer             = $('<div />', {class: "form-section", 'data-form-manager-id': $container.attr('data-form-manager-id')});
      var $fmSingleFieldContainer       = $('<div />', {class: "single-field"});
      var $fmSingleHelperFieldContainer = $('<div />', {class: "single-field"});
      var $fmFieldTitle                 = $('<div />', {class: "field_title"});
      var $fmHelperFieldTitle           = $('<div />', {class: "field_title"});
      var $fMLabel                      = $('<label />', {text: fMLabelText, class: 'fm_label'});
      var $fMHelper                     = $('<label />', {text: 'Helper', class: 'fm_label'});
      var $labelInput                   = $('<input />', {type: 'text', id: $container.attr('data-form-manager-id')+'_label_input', class: 'label_input', value: labelInputValue});
      var $helperInput                  = $('<input />', {type: 'text', id: $container.attr('data-form-manager-id')+'_helper_input', class: 'helper_input', value: helperInputValue});

      _this.$managerForm.append(
        $fmFieldContainer.append(
          $fmSingleFieldContainer.append(
            $fmFieldTitle.append(
              $fMLabel
            ),
            $labelInput
          ),
          $fmSingleHelperFieldContainer.append(
            $fmHelperFieldTitle.append(
              $fMHelper
            ),
            $helperInput
          )
        )
      );

      var $lengthInput = _this._lengthValidatedInput($container);
      if ($lengthInput) {
        $fmFieldContainer.append(_this._buildMaxLengthField(containerManagerId, $lengthInput));
      }

    });
  },

  /**
   * Text input or textarea within a field container that has a maximum length validation
   * @param {jQuery} $container - Field wrapper with a data-form-manager-id
   * @return {jQuery|null}
   */
  _lengthValidatedInput: function($container) {
    var $input = $container.find('input[data-validate], textarea[data-validate]').first();
    if ($input.length && this._lengthValidation($input)) {
      return $input;
    }
    return null;
  },

  /**
   * The Judge length validation (with a maximum) from an input's data-validate
   * @param {jQuery} $input
   * @return {Object|null}
   */
  _lengthValidation: function($input) {
    var validations = $input.data('validate');
    var lengthValidation = null;
    if ($.isArray(validations)) {
      $.each(validations, function(i, validation) {
        if (validation.kind === 'length' && validation.options && validation.options.maximum !== undefined) {
          lengthValidation = validation;
          return false;
        }
      });
    }
    return lengthValidation;
  },

  _defaultMaxLength: function(lengthValidation) {
    return lengthValidation.options.fae_default_maximum || lengthValidation.options.maximum;
  },

  /**
   * Highest max length allowed for a field: the column limit when the database reports one (rendered as maxlength),
   * otherwise a limit based on the field type
   * @param {jQuery} $input
   * @param {integer} defaultMax - The model's maximum
   * @return {integer}
   */
  _maxLengthCeiling: function($input, defaultMax) {
    var columnLimit = parseInt($input.attr('maxlength'), 10);
    if (columnLimit > 0) {
      return columnLimit;
    }
    var typeLimit = $input.is('textarea') ? this.textareaMaxLengthCeiling : this.inputMaxLengthCeiling;
    return Math.max(typeLimit, defaultMax);
  },

  _buildMaxLengthField: function(formManagerId, $input) {
    var lengthValidation = this._lengthValidation($input);
    var defaultMax       = this._defaultMaxLength(lengthValidation);
    var currentMax       = lengthValidation.options.maximum;
    var ceiling          = this._maxLengthCeiling($input, defaultMax);

    return $('<div />', {class: 'single-field'}).append(
      $('<div />', {class: 'field_title'}).append(
        $('<label />', {text: 'Max Characters', class: 'fm_label', for: formManagerId + '_max_length_input'})
      ),
      $('<input />', {
        type:                 'number',
        id:                   formManagerId + '_max_length_input',
        class:                this.maxLengthInputClass,
        min:                  Math.max(1, lengthValidation.options.minimum || 1),
        max:                  ceiling,
        step:                 1,
        placeholder:          'Set to ' + currentMax + ', Max ' + ceiling,
        'data-default-max':   defaultMax,
        'data-current-max':   currentMax
      })
    );
  },

  /**
   * Integer within the input's min/max, or '' to use the model's default.
   * A blank input keeps the current value; entering the default resets the override.
   * @param {jQuery} $maxLengthInput
   * @return {integer|string}
   */
  _sanitizeMaxLength: function($maxLengthInput) {
    var defaultMax = String($maxLengthInput.attr('data-default-max'));
    var value      = parseInt($maxLengthInput.val(), 10);
    if (isNaN(value) || value <= 0) {
      value = parseInt($maxLengthInput.attr('data-current-max'), 10);
    } else {
      value = Math.max(value, parseInt($maxLengthInput.attr('min'), 10));
      value = Math.min(value, parseInt($maxLengthInput.attr('max'), 10));
    }
    return String(value) === defaultMax ? '' : value;
  },

  /**
   * Updates a field's Judge validation and character counter with a new max length
   * @param {Object} fieldSettings - Saved settings for a field
   */
  _applyMaxLength: function(fieldSettings) {
    var $container = this.$theForm.find('['+this.containerManagerDataId+'="'+fieldSettings.formManagerId+'"]');
    var $input     = this._lengthValidatedInput($container);
    if (!$input) { return; }

    var validations      = $input.data('validate');
    var lengthValidation = this._lengthValidation($input);
    var oldMax           = lengthValidation.options.maximum;
    var newMax           = fieldSettings.maxLength === '' ? this._defaultMaxLength(lengthValidation) : parseInt(fieldSettings.maxLength, 10);
    if (newMax === oldMax) { return; }

    lengthValidation.options.maximum = newMax;
    if (lengthValidation.messages && lengthValidation.messages.too_long) {
      lengthValidation.messages.too_long = lengthValidation.messages.too_long.replace(String(oldMax), String(newMax));
    }
    $input.attr('data-validate', JSON.stringify(validations)).data('validate', validations);

    Fae.form.validator.length_counter.updateMaximum($input, newMax);
  },

  _revealManagerForm: function() {
    var _this = this;
    $('.'+_this.mainContentClass).hide();
    $('.'+_this.fmContainerClass).show();
    $('.'+_this.formManagerFormClass).fadeIn('fast');
  },

  _saveAndCloseManager: function() {
    _this = this;
    _this._submitManager();
    _this._closeManager();
  },

  _closeManager: function() {
    var _this = this;
    $('.'+_this.fmContainerClass).children().remove();
    $('.'+_this.mainContentClass).show();
  },

  _submitManager: function() {
    var _this = this;
    var payload = {
      form_manager: {
        form_manager_model_name: _this.$theForm.data('form-manager-model'),
        form_manager_model_id:   _this.$theForm.data('form-manager-model-id'),
        fields: {}
      }
    };

    // Gather everything in the inputs for a POST
    $.each(_this.$managerForm.find('['+_this.containerManagerDataId+']'), function(i) {
      var $container    = $(this);
      var formManagerId = $container.attr(_this.containerManagerDataId);
      var requiredValue = $container.hasClass('required') ? 1 : 0;

      payload.form_manager.fields[formManagerId] = {
        formManagerId: formManagerId,
        label:         $container.find('.label_input').val(),
        helper:        $container.find('.helper_input').val(),
        required:      requiredValue
      };

      var $maxLengthInput = $container.find('.'+_this.maxLengthInputClass);
      if ($maxLengthInput.length) {
        payload.form_manager.fields[formManagerId].maxLength = _this._sanitizeMaxLength($maxLengthInput);
      }
    });

    // Reset the labels/helpers to the custom ones just made
    $.each(payload.form_manager.fields, function(i, fieldSettings) {
      _this._determineFieldSetup(fieldSettings);
      if (fieldSettings.maxLength !== undefined) {
        _this._applyMaxLength(fieldSettings);
      }
    });

    $.ajax({
      url: Fae.path+'/form_managers/update',
      type: 'post',
      data: payload,
      headers: {
        'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
      },
      dataType: 'json',
      success: function (data) {
        // do something?
      }
    });

  },

  _shouldDisplayInManager: function($container) {
    var _this = this;
    var should = true;
    $(_this.ignoredFields).each(function(i, fuzzyClass) {
      if ($container.attr('class').indexOf(fuzzyClass) > -1) {
        should = false;
        return false;
      }
    });
    return should;
  },

  _capitalize: function(str) {
    return str.charAt(0).toUpperCase() + str.slice(1);
  },

  _titleize: function(str) {
    var _this = this;
    var string_array = str.split(' ');
    string_array = string_array.map(function(str) {
       return _this._capitalize(str);
    });
    return string_array.join(' ');
  }

};