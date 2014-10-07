// plugin have a checkbox in the thead of a table that controls that table column's checkboxes.
// this should be placed on the containing TH of the master checkbox.

var Hinter = {
	options: {
		icon_class: "icon-support",
		style_class: "hinter-clicker"
	},

	init: function(options, elm){
		//reference for callback
		var that = this;

		// unite the default options with the passed-in ones
		this.options = $.extend({}, this.options, options);

		// saving element reference
		this.elm = elm;
		this.height = $(elm).outerHeight();
		this.width = $(elm).outerWidth();

		// create the visuals
		this.make_icon();
		this.clicker();
		// this.hover();
	},

	make_icon: function(){
		var that = this;
		var $label = $(this.elm).parent().find("label");
		var $h6 = $label.find("h6");

		//create the icon
		that.$icon = $(document.createElement("span")).addClass(this.options.icon_class).addClass(this.options.style_class);

		// so if there's an h6 description then insert it before
		// if not, then append to the end of the label
		if ($h6.length > 0) {
			that.$icon.insertBefore($h6);
		} else {
			that.$icon.appendTo($label);
		}
	},

	clicker: function(){
		var that = this;

		that.$icon.click(function(){
			that.show_modal(this);
		});
	},

	// Allow hover to do the same as a clicking 
	hover: function(){
		var that = this;

		that.$icon.mouseenter(function() {

			$('.hinter-clicker').addClass('hovered');

			that.show_modal(this);
		});

		that.$icon.mouseleave(function() {
			$('.hinter-clicker').removeClass('hovered');
			$.modal.close();
		});
	},

	show_modal: function(elm) {
		var top = $(elm).offset().top - $(window).scrollTop();
		var left = $(elm).offset().left + 20;
		var new_height = $(elm).closest('label').siblings(".hint").height() + 80;
		var new_width = $(elm).closest('label').siblings(".hint").width() + 40;

		$(elm).closest('label').siblings(".hint").modal({
			minHeight: new_height,
			minWidth: new_width,
			position: [top, left],
			overlayClose: true,
			opacity: 0,
			containerCss: { position: "absolute" }
		});
	}
};

// make it a plugin
$.plugin("hinter", Hinter);
