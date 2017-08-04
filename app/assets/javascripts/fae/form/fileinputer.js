(function ( $ ) {
  'use strict';

  /**
   * Private initialization of FileInputer object.
   * @private
   * @class
   */
  function FileInputer($el, options) {
    /** Inherited settings from jQuery initialization */
    this.options = options;

    /** @type {jQuery} */
    this.$el = $el;
    this._drawElements();
    this.changeListener();

    return this;
  }

  /**
   * Create jQuery objects of all necessary components and add them to the DOM
   * @protected
   * @fires FileInputer._buttonListener
   * @fires FileInputer._deleterListener
   */
  FileInputer.prototype._drawElements = function() {
    this.$input = this.$el.find('input[type="file"]');

    // position the input off screen
    this.$input.css({
      position: 'absolute',
      top: 0,
      left: '-9999px',
      visibility: 'hidden'
    });

    //save the reference for each element to object
    this.$inputer = $('<div />', {
      class: this.options.wrapper_class
    });

    this.$text = $('<span />', {
      text: this.options.file_text
    });

    var $button = $('<button />', {
      class: this.options.button_class,
      attr: {
        type: 'button'
      },
      text: this.options.choose_text
    });

    var $deleter = $('<div />', {
      class: this.options.delete_class
    });

    this.$inputer
      .append($button)
      .append(this.$text)
      .append($deleter);

    this.$el.append(this.$inputer);

    this._deleterListener($deleter);
    this._buttonListener($button);
  };

  /**
   * Redirect the click on the created visuals to the file input area
   * @protected
   * @param {jQuery} $button
   */
  FileInputer.prototype._buttonListener = function($button) {
    var _this = this;

    $button.on('click', function(){
      _this.$input.click();
    });
  };

  /**
   * Clear input, set upload text, and remove active text to destroy appearance of a file uploaded
   * @protected
   * @param {jQuery} $deleter
   */
  FileInputer.prototype._deleterListener = function($deleter) {
    var _this = this;

    $deleter.on('click', function() {
      _this.$input.val('');
      _this.$text.text(_this.options.file_text);
      _this.$inputer.removeClass(_this.options.active_class);
    });
  };

  /**
   * On $input change (a file is uploaded), display file name and set field to active
   */
  FileInputer.prototype.changeListener = function() {
    var _this = this;

    // this is to get the filename and present it next to the button
    _this.$input.on('change', function(e){
      var $this = $(this);

      if (_this._checkSize()) {
        _this.$text.text( $this.val().replace('C:\\fakepath\\', '') );

        if ($this.val() !== '') {
          _this.$inputer.addClass( _this.options.active_class );
        }
      } else {
        e.preventDefault();
      }
    });
  };

  /**
   * Determine if file uploaded exceeds provided limit
   * @private
   * @return {Boolean}
   */
  FileInputer.prototype._checkSize = function() {
    var limit = parseInt( this.$input.attr('data-limit') );
    var input_files = this.$input.get(0).files;

    // IE9 doesn't support size lookups; exit early and return true to clear validation
    if (typeof input_files === undefined) {
      return true;
    }

    var size = input_files[0].size / 1024 / 1024;

    var error_obj = $('<span />', {
      class: 'error',
      text: this.$input.attr('data-exceeded').replace('###', limit)
    });

    if (size > limit) {
      this.$input.after( error_obj );
      this.$el.addClass('field_with_errors');

      return false;
    } else {
      this.$input.next('.error').remove();
      this.$el.removeClass('field_with_errors');

      return true;
    }
  };

  /**
   * A small helper library for displaying a file input field
   * @function external:"jQuery.fn".fileinputer
   */
  $.fn.fileinputer = function( options ) {

    var defaults = {
      wrapper_class: 'asset-actions',
      button_class: 'button',
      choose_text: 'ファイル選択',
      file_text: 'ファイルが選択されていません',
      active_class: 'active',
      delete_class: 'asset-delete'
    };

    // unite the default options with the passed-in ones
    var settings = $.extend( {}, defaults, options );

    return this.each(function() {
      var file = new FileInputer($(this), settings);
    });

  };

}( jQuery ));
