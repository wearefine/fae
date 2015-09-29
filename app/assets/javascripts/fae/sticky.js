'use strict';

(function ( $ ) {

  /**
   * Private initialization of Sticky object.
   * @access private
   * @class
   */
  function Sticky($el, options) {
    return this.init($el, options);
  }

  Sticky.prototype = {
    /** Inherited settings from jQuery initialization */
    options: {},
    dimensions: {},
    /** @type {jQuery} */
    $el: '',

    init: function($el, options) {
      this.options = options;
      this.$el = $el;

      var height = $el.outerHeight();
      $el.addClass('js-will-be-sticky');

			// capture dimensions
			// If a placeholder exists, use it
			this.dimensions.top = $el.offset().top - this.options.offset;
			this.dimensions.left = $el.offset().left;

			// create a placeholder
			this.createPlaceholder(height);

			// run the initial stickit
			this.stickit();

			// bind events
			this.resizer();
			this.scroller();
			FCH.resize.push(this.stickit);
    },


		createPlaceholder: function(height) {
			if (this.options.make_placeholder) {
				// create a placeholder element to use to keep the top spacing
				var $placeholder = $('<div />', {
					 class: this.options.placeholder_name,
					 css: {
						height: height,
						display: 'none'
					}
				});

				$placeholder.insertAfter(this.$el);

				// save for reference later
				this.placeholder = $placeholder;
			}
		},

		stickit: function() {
			// a wrapper to check for min_desktop.
			// we need to check for that tablet flag first. hotel detail page for tablet view doesn't show launch

			// if the min_desktop is false i.e. no min_desktop
			if (!this.options.min_desktop) {
				this.stickit_logic();
			} else if( (this.options.min_desktop && FCH.bp.large) || (FCH.dimensions.ww >= 915) ) {
				this.stickit_logic();
			} else {
				this._unStick();
			}
		},

		stickit_logic: function() {
			if (FCH.$window.scrollTop() >= this.dimensions.top) {
				// if the scroll posiiton is greater than the offset top of the sticky element
				// add class name which controls styles
				this.$placeholder.show();

				this.$el
					.addClass(this.options.class_name)
					.css({
						top: 0,
						left: this.dimensions.left,
						width: this.$placeholder.width(),
						position: 'fixed'
					});
			} else {
				this._unStick();
			}
		},

		_unStick: function() {
				this.$el
					.removeClass(this.options.class_name)
					.removeAttr('style');
				this.$placeholder.hide();
		},

		resizer: function() {
			var _this = this;

			FCH.$window.smartresize(function(){
				if ( _this.$placeholder.is(':visible')) {
					_this.dimensions.top = _this.$placeholder.offset().top - _this.options.offset;
					_this.dimensions.left = _this.$placeholder.offset().left;
				} else {
					_this.dimensions.top = _this.$el.offset().top - _this.options.offset;
					_this.dimensions.left = _this.$el.offset().left;
				}
				_this.stickit();
			});
		},

  };

  /**
   * Display helper text in a very small inline modal
   * @function external:'jQuery.fn'.sticky
   */
  $.fn.sticky = function( options ) {

    var defaults = {
			class_name: 'js-sticky',
			placeholder_name: 'js-sticky-placeholder',
			make_placeholder: true,
			offset: 0,
			min_desktop: true,
			header_selector: '#main_header'
    };

    // unite the default options with the passed-in ones
    var settings = $.extend( {}, defaults, options );

    return this.each(function() {
      var sticker = new Sticky($(this), settings);
    });

  };

}( jQuery ));
