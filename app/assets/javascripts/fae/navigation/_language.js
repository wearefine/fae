/* global Fae */

'use strict';

/**
 * Fae navigation language
 * @namespace navigation.language
 * @memberof navigation
 */
Fae.navigation.language = {

  el: {},

  init: function(options, elm){
    /** Stores shared jQuery objects in Fae.navigation.language.el */
    this.el.$toggles = $('.main_content-section-toggles');
    this.el.$lang_divs = $('div[data-language]');

    if (this.el.$toggles.length) {
      this.setInitialState();
      this.addNavEvents();
    }
  },

  /**
   * Reads the language of the active toggle on load and shows the corresponding fields
   */
  setInitialState: function() {
    var lang = this.el.$toggles.find('.active').data('language');
    this._toggleLanguageFields(lang, 0);
  },

  /**
   * Adds the click events to the toggle btns
   */
  addNavEvents: function() {
    var _this = this;

    _this.el.$toggles.on('click', 'a', function(ev) {
      ev.preventDefault();

      var $this = $(this);
      var lang = $this.data('language');

      // if btn is not already active
      if (!$this.hasClass('active')) {
        _this._toggleLanguageFields(lang, 200);

        // set btn to active
        _this.el.$toggles.find('.active').removeClass('active');
        $this.addClass('active');

        _this._saveLanguagePreference(lang);
        _this._removeHiddenErrorsMessage();
      }
    });
  },

  /**
   * Hides all language fields and fades in ones according to language
   * @access protected
   * @param {String} lang - Language of fields to fade in
   * @param {Number} speed - Speed of the fade transitions in ms
   */
  _toggleLanguageFields: function(lang, speed) {
    var _this = this;
    _this.el.$lang_divs.fadeOut(speed).promise().done(function() {
      if (lang) {
        $('div[data-language='+lang+']').fadeIn(speed);
      } else {
        _this.el.$lang_divs.fadeIn(speed);
      }
    });
  },

  /**
   * POSTs to Utilities#language_preference to save user's language preference
   * @access protected
   * @param {String} lang - Preferred language
   */
  _saveLanguagePreference: function(lang) {
    lang = lang || 'all'
    var post_url = Fae.path + '/language_preference/' + lang;
    $.post(post_url);
  },

  /**
   * Called on form validation; checks for hidden fields with errors and displays a message
   * @see {@link form.validator.formValidate}
   */
  checkForHiddenErrors: function() {
    if (this.el.$toggles.length && $('div.field_with_errors:hidden').length && !$('.hidden_errors').length) {
      $(Fae.content_selector).prepend('<div class="hidden_errors field_with_errors"><span class="error">There are hidden errors. Click "All Languages" in the language nav to view all errors.</span></div>');
    }
  },

  /**
   * Fade out extra error messages
   * @access protected
   * @see {@link navigation.language.addNavEvents}
   */
  _removeHiddenErrorsMessage: function() {
    $('.hidden_errors').fadeOut(200, function() {
      $(this).remove();
    });
  },

};
