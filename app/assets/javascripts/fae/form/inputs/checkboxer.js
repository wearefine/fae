// plugin have a checkbox in the thead of a table that controls that table column's checkboxes.
// this should be placed on the containing TH of the master checkbox.

var Checkboxer = {
	options: {
		class_name: "js-active"
	},

	init: function(options, elm){
		//reference for callback
		var that = this;

		// unite the default options with the passed-in ones
		this.options = $.extend({}, this.options, options);

		// saving element reference
		this.elm = elm;
		this.th = elm;

		// saving table column, table parent
		this.column = $(elm).index() + 1;
		this.table = $(elm).closest("table");

		// save the group of tbdoy tds
		this.tds = $(this.table).find("td:nth-child(" + this.column + ")");

		// makes it all start working
		this.td_event();
		this.th_event();
	},

	get_checked: function() {
		return $(this.tds).find(":checked");
	},

	td_event: function(){
		var that = this;
		var $checkboxes = $(this.tds).find(":checkbox");

		$checkboxes.change(function(){
			var $th = $(that.table).find(that.th);
			var $td = $(that.tds);
			var $td_checked = that.get_checked();

			$(this).siblings("label").toggleClass(that.options.class_name);

			if($td.length == $td_checked.length) {
				$th.find(":checkbox").prop("checked", true);
				$th.find("label").addClass(that.options.class_name);
			} else {
				$th.find(":checkbox").removeAttr("checked");
				$th.find("label").removeClass(that.options.class_name);
			}
		});
	},

	th_event: function() {
		var that = this;
		$(that.th).find("label").click(function(){
			var $td = $(that.tds);

			if ($(this).hasClass(that.options.class_name)) {
				$(this).removeClass(that.options.class_name);

				// uncheck all checkboxes
				$td.find(":checkbox").removeAttr("checked");
				// remove the class to the labels for the icons
				$td.find("label").removeClass(that.options.class_name);
			} else {
				$(this).addClass(that.options.class_name);
				// check all checkboxes\
				$td.find(":checkbox").prop("checked", true);
				// add the class to the labels for the icons
				$td.find("label").addClass(that.options.class_name);
			}
		});
	}
};

// make it a plugin
$.plugin("checkboxer", Checkboxer);
