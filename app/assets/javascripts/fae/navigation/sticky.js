/* global FCH */

(function ( $ ) {
  'use strict';

  /**
   * Adjust offsets
   * @private
   * @param {jQuery} $el
   * @see Sticky.windowListeners
   */
  function setDimensionsTopLeft($el) {
    this.dimensions.top = $el.offset().top - this.options.offset;
    this.dimensions.left = $el.offset().left;
  }

  /**
   * Private initialization of Sticky object.
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
    if (this.options.placeholder) {
      this.createPlaceholder(height);
    }

    // run the initial stickIt
    this.stickIt();

    // bind events
    this.windowListeners();

    return this;
  }

  /**
   * Create a placeholder element to use to keep the top spacing
   * @param {Number} height - Size of stuck element
   */
  Sticky.prototype.createPlaceholder = function(height) {
    var css_properties = {
      height: height,
      visibility: 'hidden'
    };

    if(!this.options.perpetual_placeholder) {
      css_properties.display = 'none';
    }

    var $placeholder = $('<div />', {
       class: this.options.placeholder_class,
       css: css_properties
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
      if (this.options.placeholder) {
        this.$placeholder.show();
      }

      this.$el
        .addClass(this.options.class_name)
        .css({
          top: Fae.navigation.peek.getPeekHeight(),
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
      .css({
        top: '',
        left: '',
        position: ''
      });

    if (this.options.placeholder && !this.options.perpetual_placeholder) {
      this.$placeholder.hide();
    }
  };

  /**
   * Listen for scroll and smartresize to stick or unstick element
   */
  Sticky.prototype.windowListeners = function() {
    var _this = this;

    function scrollCallback() {
      _this.stickIt();
    }

    function resizePlaceholder() {
      _this.$placeholder.css( 'height', _this.$el.outerHeight() );
    }

    function debounceResizeCallback() {
      if ( _this.$placeholder && _this.$placeholder.is(':visible')) {
        setDimensionsTopLeft.call(_this, _this.$placeholder);
      } else {
        setDimensionsTopLeft.call(_this, _this.$el);
      }

      _this.stickIt();
    }

    FCH.scroll.push( scrollCallback );
    FCH.resize.push( FCH.debounce( debounceResizeCallback ) );

    debounceResizeCallback();

    if (this.options.placeholder) {
      FCH.resize.push( resizePlaceholder );
    }
  };

  /**
   * Stick elements within the viewport
   * @function external:'jQuery.fn'.sticky
   */
  $.fn.sticky = function( options ) {
    var defaults = {
      class_name: 'js-sticky',
      placeholder_class: 'js-sticky-placeholder',
      placeholder: false,
      offset: 0,
      perpetual_placeholder: false
    };

    // unite the default options with the passed-in ones
    var settings = $.extend( {}, defaults, options );

    return this.each(function() {
      var sticker = new Sticky($(this), settings);
    });

  };

}( jQuery ));
