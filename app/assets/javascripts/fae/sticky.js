var Sticky = {
	options: {
		class_name: "js-sticky",
		placeholder_name: "js-sticky-placeholder",
		make_placeholder: true
	},

	init: function(options, elm){
		//reference for callback
		var that = this;

		// unite the default options with the passed-in ones
		this.options = $.extend({}, this.options, options);

		// saving element reference
		this.elm = elm;

		// capture top and left
		this.height = $(this.elm).outerHeight();
		this.top = $(this.elm).offset().top;
		this.left = $(this.elm).offset().left;

		// create a placeholder
		if (this.options.make_placeholder) {
			this.createPlaceholder();
		}

		// run the initial stickit and events
		this.stickit();
		this.resizer();
		this.scroller();
	},

	createPlaceholder: function() {
		// create a placeholder element to use to keep the top spacing
		var placeholder = $(document.createElement("div")).addClass(this.options.placeholder_name).css({
			height: this.height,
			display: "none"
		});
		$(placeholder).insertAfter($(this.elm));

		// save for reference later
		this.placeholder = placeholder;
	},

	stickit: function() {
		var that = this;
		var $elm = $(this.elm);
		var $placeholder = $(this.placeholder);

		if ($(window).scrollTop() > this.top) {
			// if the scroll posiiton is greater than the offset top of the sticky element
			// add class name which controls styles
			$placeholder.show();
			$elm.addClass(this.options.class_name).css({
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
		$(window).on("resize", function(){
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