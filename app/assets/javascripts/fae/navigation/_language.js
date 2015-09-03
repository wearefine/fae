/* global Fae */

'use strict';

Fae.navigation.language = {

	init: function(options, elm){
		this.set_elements();

		if (this.el.$toggles.length) {
			this.set_initial_state();
			this.add_nav_events();
		}
	},

	// stores shared jQuery objects in LanguageNav.el
	set_elements: function() {
		this.el.$toggles = $('.main_content-section-toggles');
		this.el.$lang_divs = $('div[data-language]');
	},

	// reads the language of the active toggle on load
	// and shows the corresponding fields
	set_initial_state: function() {
		var lang = this.el.$toggles.find('.active').data('language');
		this.toggle_language_fields(lang, 0);
	},

	// adds the click events to the toggle btns
	add_nav_events: function() {
		var _this = this;

		_this.el.$toggles.on('click', 'a', function(ev) {
			ev.preventDefault();

			var $this = $(this);
			var lang = $this.data('language');

			// if btn is not already active
			if (!$this.hasClass('active')) {
				_this.toggle_language_fields(lang, 200);

				// set btn to active
				_this.el.$toggles.find('.active').removeClass('active');
				$this.addClass('active');

				_this.save_language_preference(lang);
				_this.remove_hidden_errors_message();
			}
		});
	},

	// hides all language fields and fades in ones according to language
	// args:
	//   lang: (string) language of fields to fade in
	//   speed: (integer) speed of the fade transitions
	toggle_language_fields: function(lang, speed) {
		var _this = this;
		_this.el.$lang_divs.fadeOut(speed).promise().done(function() {
			if (lang) {
				$('div[data-language='+lang+']').fadeIn(speed);
			} else {
				_this.el.$lang_divs.fadeIn(speed);
			}
		});
	},

	// posts to Utilities#language_preference to save user's language preference
	save_language_preference: function(lang) {
		lang = lang || 'all'
		var post_url = Admin.path + '/language_preference/' + lang;
		$.post(post_url);
	},

	// called from form_validate.form_validate
	// checks for hidden fields with errors and displays a message
	check_for_hidden_errors: function() {
		if (this.el.$toggles.length && $('div.field_with_errors:hidden').length && !$('.hidden_errors').length) {
			$('.main_content-section-area').prepend('<div class="hidden_errors field_with_errors"><span class="error">There are hidden errors. Click "All Languages" in the language nav to view all errors.</span></div>');
		}
	},

	remove_hidden_errors_message: function() {
		$('.hidden_errors').fadeOut(200, function() {
			$(this).remove();
		});
	},

	el: {}

};
