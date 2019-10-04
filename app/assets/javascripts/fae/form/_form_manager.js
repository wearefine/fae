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
  requiredEl:               '<abbr title="required">*</abbr>',
  containerManagerDataIds:  'data-form_manager_id',
  hiddenWhenLaunchedEls: [
    'input',
    'textarea:not(".mde-enabled, .trumbowyg-textarea")',
    'label',
    '.counter',
    '.markdown-support',
    '.daterangepicker-seperator',
    '.asset-inputs',
    '.chosen-container',
    '.ms-container',
    '.editor-toolbar',
    '.CodeMirror',
    '.trumbowyg-box',
    '.hinter-clicker'
  ],

  init: function(formSelector) {
    var _this = this;
    formSelector = formSelector || 'form:first';
    _this.$theForm = $(formSelector);

    if (_this.$theForm.length && _this.$theForm.attr(_this.infoAttr)) {
      this.savedFieldSettings = JSON.parse(_this.$theForm.attr(_this.infoAttr));

      $.each(JSON.parse(this.savedFieldSettings.fields), function(i, fieldSettings) {
        _this.setupField(fieldSettings);
      });
    }

    $('body').on('click', '.'+_this.launchManagerClass, function(e) {
      e.preventDefault();
      _this.$theForm = $(this).parents('form');
      _this.launchManager($(this));
    });

    $('body').on('click', '.'+_this.saveAndCloseManagerClass, function(e) {
      e.preventDefault();
      _this.saveAndCloseManager($(this));
    });

  },

  setupField: function(fieldSettings) {
    var _this = this;
    var $container = $('[data-form_manager_id="'+fieldSettings.formManagerId+'"]');
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

  launchManager: function($launchButton) {
    var _this = this;

    $(_this.hiddenWhenLaunchedEls).each(function(i, className) {
      _this.$theForm.find(className).hide();
    });

    $(_this.$theForm.find('['+_this.containerManagerDataIds+']')).each(function(i) {
      var $container = $(this);
      var $label        = $container.find('label:first');
      var $labelTextEl  = $label;
      var $labelInner   = $label.find('.label_inner');
      if ($labelInner.length) {
        $labelTextEl = $labelInner;
      }
      var $helperTextTextEl = $label.find('.'+_this.helperTextTextElClass);
      var labelValue    = $labelTextEl.clone().children().remove().end().text().replace('*','').trim();
      var helperValue   = $helperTextTextEl.text();
      var $labelInput = $('<input />', {type: 'text', class: 'form_manager_label_input label_input', value: labelValue});
      var $helperInput = $('<input />', {type: 'text', class: 'form_manager_label_input helper_input', value: helperValue});

      $label.hide();

      $container.append($labelInput).append($helperInput);
    });

    $launchButton.removeClass(_this.launchManagerClass);
    $launchButton.addClass(_this.saveAndCloseManagerClass);
  },

  saveAndCloseManager: function($launchButton) {
    var _this = this;

    _this.submitManager();

    $('.form_manager_label_input').remove();

    $(_this.hiddenWhenLaunchedEls).each(function(i, className) {
      _this.$theForm.find(className).show();
    });

    $launchButton.removeClass(_this.saveAndCloseManagerClass);
    $launchButton.addClass(_this.launchManagerClass);
  },

  submitManager: function() {
    var _this = this;
    var payload = {
      form_manager: {
        form_manager_model_name: _this.$theForm.data('form-manager-model'),
        form_manager_model_id:   _this.$theForm.data('form-manager-model-id'),
        fields: {}
      }
    };

    // set the forms info attr to new payload and rerun setup fields

    $.each(_this.$theForm.find('['+_this.containerManagerDataIds+']'), function(i) {
      var $container    = $(this);
      var formManagerId = $container.attr(_this.containerManagerDataIds);
      // var $label        = $container.find('label:first');
      // var $labelTextEl  = $label;
      // var $labelInner   = $label.find('.label_inner');
      // if ($labelInner.length) {
      //   $labelTextEl = $labelInner;
      // }
      // var $helperTextTextEl = $label.find('.'+_this.helperTextTextElClass);
      // var labelValue    = $labelTextEl.clone().children().remove().end().text().replace('*','').trim();
      // var helperValue   = $helperTextTextEl.text();
      var requiredValue = $container.hasClass('required') ? 1 : 0;

      payload.form_manager.fields[formManagerId] = {
        formManagerId: formManagerId,
        label:         $container.find('.label_input').val(),
        helper:        $container.find('.helper_input').val(),
        required:      requiredValue
      };
    });

    $.each(payload.form_manager.fields, function(i, fieldSettings) {
      _this.setupField(fieldSettings);
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


  }

};