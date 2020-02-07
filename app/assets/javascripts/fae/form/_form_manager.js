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
        _this._setupField($captionContainer, captionLabel, null);
      }
      if ($altContainer) {
        var altLabel = fieldSettings.label + ' Alt Text';
        _this._setupField($altContainer, altLabel, null);
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
      if ($container.hasClass('required') || $label.hasClass('required')) {
        newLabelText = _this.requiredEl;
      }

      newLabelText += overriddenLabel;
      $labelTextEl.html(newLabelText);

      if($labelsCheckbox.length) {
        $labelTextEl.append($labelsCheckbox);
      }

      if (overriddenHelper) {
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

    });
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
    });

    // Reset the labels/helpers to the custom ones just made
    $.each(payload.form_manager.fields, function(i, fieldSettings) {
      _this._determineFieldSetup(fieldSettings);
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