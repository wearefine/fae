// plugin have a checkbox in the thead of a table that controls that table column's checkboxes.
var FileInputer = {
	options: {
		wrapper_class: "file_input-wrapper",
		button_class: "file_input-button",
		delete_class: "file_input-delete",
		text: "Choose File",
		file_text: "No File Chosen",
		active_class: "js-active"
	},

	init: function(options, elm){
		//reference for callback
		var that = this;

		// unite the default options with the passed-in ones
		this.options = $.extend({}, this.options, options);

		// saving element reference
		this.elm = elm;
		this.$input = $(elm).find("input[type=file]");

		// create the visuals
		this.make_visuals();

		// make the events
		this.clicker();
		this.onchanger();
		this.deleter();
	},

	make_visuals: function() {
		// positoin the input off screen
		this.$input.css({
			"position": "absolute",
			"top": 0,
			"left": "-9999px",
			"visibility": "hidden"
		});

		//save the reference for each element to object
		this.$inputer = $(document.createElement("div")).addClass(this.options.wrapper_class);
		this.$button = $(document.createElement("button")).addClass(this.options.button_class).attr("type", "button").text(this.options.text);
		this.$text = $(document.createElement("span")).text(this.options.file_text);
		this.$deleter = $(document.createElement("div")).addClass(this.options.delete_class);

		this.$inputer.append(this.$button).append(this.$text).append(this.$deleter);
		$(this.elm).append(this.$inputer);
	},

	clicker: function() {
		var that = this;

		// redirect the click on the created visuals to the file input area
		this.$button.on("click", function(){
			that.$input.click();
		});
	},

	deleter: function() {
		var that = this;
		this.$deleter.on("click", function() {
			that.$input.val("");
			that.$text.text(that.options.file_text);
			that.$inputer.removeClass(that.options.active_class);
		});
	},

	onchanger: function() {
		var that = this;

		// this is to get the filename and present it next to the button
		this.$input.on("change", function(){
			that.$text.text($(this).val().replace("C:\\fakepath\\", ""));

			if ($(this).val() !== "") {
				that.$inputer.addClass(that.options.active_class);
			}
		});
	}
};

// make it a plugin
$.plugin("fileinputer", FileInputer);
