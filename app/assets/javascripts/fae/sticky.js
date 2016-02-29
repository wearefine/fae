/* global FCH */

'use strict';

(function ( $ ) {

  /**
   * Private initialization of Sticky object.
   * @access private
   * @class
   */
  function Sticky($el, options) {
    /** @type {jQuery} */
    this.$el = $el;

    /** Inherited settings from jQuery initialization */
    this.options = options;

    // capture dimensions
    // If a placeholder exists, use it
    this.dimensions = {
      top: $el.offset().top - this.options.offset,
      left: $el.offset().left
    };

    var height = $el.outerHeight();
    $el.addClass('js-will-be-sticky');

    // create a placeholder
    if (this.options.make_placeholder) {
      this.createPlaceholder(height);
    }

    // run the initial stickIt
    this.stickIt();

    // bind events
    this.windowListeners();

    return this;
  };

  /**
   * Create a placeholder element to use to keep the top spacing
   * @param {Number} height - Size of stuck element
   */
  Sticky.prototype.createPlaceholder = function(height) {
    var $placeholder = $('<div />', {
       class: this.options.placeholder_name,
       css: {
        height: height,
        display: 'none'
      }
    });

    $placeholder.insertAfter(this.$el);
    // save for reference later
    this.$placeholder = $placeholder;
  };

  /**
   * On window scroll, check to make sure the screen is larger than table and if it isn't, unstick it
   * @fires stickItLogic (Conditionally)
   * @fires _unStick (Conditionally)
   */
  Sticky.prototype.stickIt = function() {
    if (FCH.bp.large) {
      this._stickItLogic();
    } else {
      this._unStick();
    }
  };

  /**
   * Fix sticky element to top of page if it's past originally-set boundary.
   * @access protected
   * @fires _unStick (Conditionally)
   * @see stickIt
   */
  Sticky.prototype._stickItLogic = function() {
    if (FCH.$window.scrollTop() >= this.dimensions.top) {
      if (this.options.make_placeholder) {
        this.$placeholder.show();
        this.$el.css({ width: this.$placeholder.width() });
      }

      this.$el
        .addClass(this.options.class_name)
        .css({
          top: 0,
          left: this.dimensions.left,
          position: 'fixed'
        });
    } else {
      this._unStick();
    }
  };

  /**
   * Remove active class and fixed styles from targeted element; hide placeholder
   */
  Sticky.prototype._unStick = function() {
    this.$el
      .removeClass(this.options.class_name)
      .removeAttr('style');

    if (this.options.make_placeholder) {
      this.$placeholder.hide();
    }
  };

  /**
   * Listen for scroll and smartresize to stick or unstick element
   */
  Sticky.prototype.windowListeners = function() {
    var _this = this;

    var scrollCallback = function() {
      _this.stickIt();
    };
    FCH.scroll.push(scrollCallback);

    FCH.$window.smartresize(function(){
      if ( _this.$placeholder && _this.$placeholder.is(':visible')) {
        _this.dimensions.top = _this.$placeholder.offset().top - _this.options.offset;
        _this.dimensions.left = _this.$placeholder.offset().left;

      } else {
        _this.dimensions.top = _this.$el.offset().top - _this.options.offset;
        _this.dimensions.left = _this.$el.offset().left;

      }

      _this.stickIt();
    });
  };

  /**
   * Stick elements within the viewport
   * @function external:'jQuery.fn'.sticky
   */
  $.fn.sticky = function( options ) {

    var defaults = {
      class_name: 'js-sticky',
      placeholder_name: 'js-sticky-placeholder',
      make_placeholder: true,
      offset: 0,
      header_selector: '#js-main-header'
    };

    // unite the default options with the passed-in ones
    var settings = $.extend( {}, defaults, options );

    return this.each(function() {
      var sticker = new Sticky($(this), settings);
    });

  };

}( jQuery ));
