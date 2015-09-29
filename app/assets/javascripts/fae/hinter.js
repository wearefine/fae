'use strict';

(function ( $ ) {

  /**
   * Private initialization of Hinter object.
   * @access private
   * @class
   */
  function Hinter($el, options) {
    /** Inherited settings from jQuery initialization */
    this.options = options;
    this._drawElements($el);
    this._clickListener();
    // this._hoverListener();

    return this
  }

  /**
   * Create jQuery object of the $icon and add it to the DOM
   * @access protected
   */
  Hinter.prototype._drawElements = function($el) {
    var $label = $el.parent().find('label');
    var $h6 = $label.find('h6');

    //create the icon
    this.$icon = $('<span />', {
      class: this.options.icon_class + ' ' + this.options.style_class
    });

    // so if there's an h6 description then insert it before
    // if not, then append to the end of the label
    if ($h6.length) {
      this.$icon.insertBefore($h6);
    } else {
      this.$icon.appendTo($label);
    }
  };

  /**
   * Show the modal on click
   * @access protected
   */
  Hinter.prototype._clickListener = function() {
    var _this = this;

    _this.$icon.click(function(){
      _this._showModal( $(this) );
    });
  };

  /**
   * Allow hover to do the same as a clicking
   */
  Hinter.prototype._hoverListener = function(){
    var _this = this;
    var $clicker = $('.hinter-clicker');

    _this.$icon.mouseenter(function() {
      $clicker.addClass('hovered');
      _this._showModal( $(this) );
    });

    _this.$icon.mouseleave(function() {
      $clicker.removeClass('hovered');
      $.modal.close();
    });
  };

  /**
   * Display inline modal of helper text. This is the bread and butter of the plugin.
   * @access private
   * @param {jQuery} $el - The object to display the text relative to
   */
  Hinter.prototype._showModal = function($el) {
    var top = $el.offset().top - FCH.$window.scrollTop();
    var left = $el.offset().left + 20;
    var new_height = $el.closest('label').siblings('.hint').height() + 80;
    var new_width = $el.closest('label').siblings('.hint').width() + 40;
    var $hint = $el.closest('label').siblings('.hint');

    $hint.modal({
      minHeight: new_height,
      minWidth: new_width,
      position: [top, left],
      overlayClose: true,
      opacity: 0,
      containerCss: { position: 'absolute' },
      onShow: function(){
        if ($hint.find('.dark').length) {
          $('#simplemodal-container').addClass('simplemodal-container--dark')
        };
      }
    });

  };

  /**
   * Display helper text in a very small inline modal
   * @function external:'jQuery.fn'.hinter
   */
  $.fn.hinter = function( options ) {

    var defaults = {
      icon_class: 'icon-support',
      style_class: 'hinter-clicker'
    };

    // unite the default options with the passed-in ones
    var settings = $.extend( {}, defaults, options );

    return this.each(function() {
      var hint = new Hinter($(this), settings);
    });

  };

}( jQuery ));
