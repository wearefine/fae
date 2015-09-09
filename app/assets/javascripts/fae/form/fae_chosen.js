// this plugin sets chosen defaults and massages options based on class names

var FaeChosen = {
	options: {
		disable_search_threshold: 10
	},

	init: function(options, elm){
		// unite the default options with the passed-in ones
		this.options = $.extend({}, this.options, options);

		var $elm = $(elm);

		// remove threshold if show_search class is added from `search: true`
		if ($elm.hasClass('select-search')) {
			this.options.disable_search_threshold = 0;
		}

		$(elm).chosen(this.options);
	}

};

// make it a plugin
$.plugin("fae_chosen", FaeChosen);
