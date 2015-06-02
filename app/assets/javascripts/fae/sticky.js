var Sticky = {
	options: {
		class_name: "js-sticky",
		placeholder_name: "js-sticky-placeholder",
		make_placeholder: true,
		hero_selector: false,
		offset: 300,
		min_desktop: false,
		min_search_compare: false, // search and compare page not for small widths -- set to 650
		header_selector: "#main_header"
	},

	init: function(options, elm){
		//reference for callback
		var that = this;

		// unite the default options with the passed-in ones
		this.options = $.extend({}, this.options, options);

		// saving element reference
		this.elm = elm;

		// set the height
		this.height = $(this.elm).outerHeight();
		$(this.elm).addClass('js-will-be-sticky');
		// if it has a hero area, we need to wait before grabbing its top/left...because images.
		if (this.options.hero_selector) {
			$(this.options.hero_selector).imagesLoaded( function() {
				that.startup_sequence();
			});
		} else {
			this.startup_sequence();
		}
	},

	startup_sequence: function() {
		// capture dimensions
		this.set_position();

		// create a placeholder
		this.createPlaceholder();

		// run the initial stickit
		this.stickit();

		// bind events
		this.resizer();
		this.scroller();
	},

	set_position: function() {
		// capture position. if placeholder exists, use it
		this.top = $(this.elm).offset().top - this.options.offset;
		this.left = $(this.elm).offset().left;
	},

	createPlaceholder: function() {
		if (this.options.make_placeholder) {
			// create a placeholder element to use to keep the top spacing
			var placeholder = $(document.createElement("div")).addClass(this.options.placeholder_name).css({
				height: this.height,
				display: "none"
			});
			$(placeholder).insertAfter($(this.elm));

			// save for reference later
			this.placeholder = placeholder;
		}
	},

	stickit: function() {
		// a wrapper to check for min_desktop.
		// we need to check for that tablet flag first. hotel detail page for tablet view doesn't show launch

		// if the min_desktop is false i.e. no min_desktop
		if (!this.options.min_desktop && !this.options.min_search_compare) {
			this.stickit_logic();
		} else if(
			(this.options.min_desktop && $(window).width() >= 1024) ||
			(this.options.min_search_compare && $(window).width() >= 915)
		) {
			this.stickit_logic();
		} else {
			$(this.elm).removeClass(this.options.class_name).removeAttr("style");
			$(this.placeholder).hide();
		}
	},

	stickit_logic: function() {
		var that = this;
		var $elm = $(this.elm);
		var $placeholder = $(this.placeholder);

		if ($(window).scrollTop() >= this.top) {
			// if the scroll posiiton is greater than the offset top of the sticky element
			// add class name which controls styles
			$placeholder.show();

			$elm.addClass(this.options.class_name).css({
				top: 0,
				left: that.left,
				width: $placeholder.width(),
				position: "fixed"
			});
		} else {
			$elm.removeClass(this.options.class_name).removeAttr("style");
			$placeholder.hide();
		}
	},

	resizer: function() {
		var that = this;

		$(window).smartresize(function(){
			if ($(that.placeholder).is(":visible")) {
				that.top = $(that.placeholder).offset().top - that.options.offset;
				that.left = $(that.placeholder).offset().left;
			} else {
				that.top = $(that.elm).offset().top - that.options.offset;
				that.left = $(that.elm).offset().left;
			}
			that.stickit();
		});
	},

	scroller: function() {
		var that = this;
		$(window).on("scroll", function(){
			that.stickit();
		});
	}
};
// make it a plugin
$.plugin("sticky", Sticky);