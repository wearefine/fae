/* global Fae */

/**
 * Fae form manager
 * @namespace form
 * @memberof Fae
 */
Fae.form.formManager = {

  $theForm:                 null,
  savedFieldSettings:       null,
  launchManagerClass:       'js-launch-form-manager',
  saveAndCloseManagerClass: 'js-manager-is-active',
  helperTextTextElClass:    'helper_text_text',
  infoAttr:                 'data-form-manager-info',
  languageAttr:             'data-language',
  requiredEl:               '<abbr title="required">*</abbr> ',
  containerManagerDataId:  'data-form-manager-id',
  formManagerBodyClass:     'form-manager-is-active',
  ignoresHiddenClass:       'ignores-are-hidden',
  hiddenWhenLaunchedEls: [
    'input',
    'textarea:not(".mde-enabled, .trumbowyg-textarea")',
    'label',
    '.counter',
    '.markdown-support',
    '.daterangepicker-seperator',
    '.asset-inputs',
    '.asset-actions',
    '.chosen-container',
    '.ms-container',
    '.editor-toolbar',
    '.CodeMirror',
    '.trumbowyg-box',
    '.hinter-clicker',
    '#js-header-cancel',
    '#js-header-clone',
    '.js-multiselect-action-deselect_all'
  ],
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

  },

  setupAllFields: function($theForm) {
    _this = this;
    if ($theForm.length && $theForm.attr(_this.infoAttr)) {
      this.savedFieldSettings = JSON.parse($theForm.attr(_this.infoAttr));

      $.each(JSON.parse(this.savedFieldSettings.fields), function(i, fieldSettings) {
        _this._setupField(fieldSettings);
      });
    }
  },

  _setupField: function(fieldSettings) {
    var _this = this;
    var $container = $('[data-form-manager-id="'+fieldSettings.formManagerId+'"]');
    if ($container.length) {
      var $label                 = $container.find('label:first');
      var $helperTextContainerEl = $container.find('h6');
      var $labelInner            = $label.find('.label_inner');
      var $labelTextEl           = $label;
      if ($labelInner.length) {
        $labelTextEl = $labelInner;
      }

      // var $labelsCheckbox = $labelTextEl.find('input');

      //var existingLabelText = $labelTextEl.html();
      var newLabelText = '';
      if ($container.hasClass('required')) {
        newLabelText = _this.requiredEl;
      }

      newLabelText += fieldSettings.label;
      $labelTextEl.html(newLabelText);
      // if ($labelsCheckbox.length) {
      //   $labelTextEl.append($labelsCheckbox);
      // }
      if (fieldSettings.helper) {
        $label.removeClass('has_no_helper_text');

        // Main form and nested form markup differs, deal with it
        if ($container.find('h6').length) {
          $label.find('.'+_this.helperTextTextElClass).text(fieldSettings.helper);
        } else {
          if (!$helperTextContainerEl.length) {
            $helperTextContainerEl = $('<h6 />', {class: 'helper_text'}).append($('<span />', {class: 'helper_text_text', text: fieldSettings.helper}));
          } else {
            $helperTextContainerEl.find('.'+_this.helperTextElClass).text(fieldSettings.helper);
          }
          $label.append($helperTextContainerEl);
        }
      }
    }
  },

  _launchManager: function($launchButton) {
    var _this = this;
    $('body').addClass(_this.formManagerBodyClass);

    // Show all language inputs!
    _this.$theForm.find('['+_this.languageAttr+']').show();

    // Hide all the things
    $(_this.hiddenWhenLaunchedEls).each(function(i, className) {
      _this.$theForm.find(className).hide();
    });

    // Insert a bunch of inputs for label/helper text
    $(_this.$theForm.find('['+_this.containerManagerDataId+']')).each(function(i) {
      var $container    = $(this);
      if (!$container.is(':visible') || $container.hasClass('hidden')) { return; }

      // Expicit ignores
      _this._ignoredFields('hide', $container);

      var $label        = $container.find('label:first');
      var $labelTextEl  = $label;
      var $labelInner   = $label.find('.label_inner');
      if ($labelInner.length) {
        $labelTextEl = $labelInner;
      }
      var $helperTextTextEl = $label.find('.'+_this.helperTextTextElClass);
      var iDParts           = $container.attr(_this.containerManagerDataId).split('_');
      iDParts.shift();
      var fMLabelText       = _this._titleize(iDParts.join(' '));
      var labelInputValue   = $labelTextEl.clone().children().remove().end().text().replace('*','').trim();
      var helperInputValue  = $helperTextTextEl.text();
      var $fMLabel          = $('<label />', {text: fMLabelText, class: 'fm_label'});
      var $labelInput       = $('<input />', {type: 'text', id: $container.attr('data-form-manager-id')+'_label_input', class: 'label_input', value: labelInputValue});
      var $helperInput      = $('<input />', {type: 'text', id: $container.attr('data-form-manager-id')+'_helper_input', class: 'helper_input', value: helperInputValue});

      $label.hide();

      $container.append($fMLabel).append($labelInput).append($helperInput);
    });

    $launchButton.text($launchButton.attr('data-save-prompt'));
    $launchButton.removeClass(_this.launchManagerClass);
    $launchButton.addClass(_this.saveAndCloseManagerClass);
  },

  _saveAndCloseManager: function($launchButton) {
    var _this = this;
    $('body').removeClass(_this.formManagerBodyClass);

    _this._submitManager();

    // Get rid of form manager els
    $('.label_input, .helper_input, .fm_label').remove();

    // Reveal hidden things
    $(_this.hiddenWhenLaunchedEls).each(function(i, className) {
      _this.$theForm.find(className).show();
    });

    //Restore ignores
    _this._ignoredFields('show', null);

    $launchButton.text($launchButton.attr('data-launch-prompt'));
    $launchButton.removeClass(_this.saveAndCloseManagerClass);
    $launchButton.addClass(_this.launchManagerClass);
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
    $.each(_this.$theForm.find('['+_this.containerManagerDataId+']'), function(i) {
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
      _this._setupField(fieldSettings);
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

  _ignoredFields: function(type, $container) {
    var _this = this;
    switch(type) {
      case 'show':
        $('.'+_this.ignoresHiddenClass).show().removeClass(_this.ignoresHiddenClass);
        break;
      case 'hide':
        $(_this.ignoredFields).each(function(i, fuzzyClass) {
          if ($container.attr('class').indexOf(fuzzyClass) !== -1) {
            $container.hide().addClass(_this.ignoresHiddenClass);
          }
        });
        break;
    }
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