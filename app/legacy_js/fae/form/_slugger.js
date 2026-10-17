/* global Fae */

'use strict';

/**
 * Fae form
 * @namespace form
 * @memberof Fae
 */
Fae.form.slugger = {
  init: function() {
    this.addListener();
  },

  /**
   * Attach listeners to inputs and update slug fields with original safe values from the original inputs
   */
  addListener: function() {
    var _this = this;

    Fae.fresh($('.slug'), 'slugger').each(function() {
      var $form = $(this).closest('form, .js-nested-form-container');
      var $sluggers = $form.find('.slugger');
      var $slug = $form.find('.slug');
      var $select_slugger = $form.find('.select.slugger');

      if ($slug.val() !== '') {
        $sluggers.removeClass('slugger');

      } else {
        // If it's a text field, listen for type input
        $sluggers.keyup(function(){
          var text = _this._digestSlug( $sluggers );
          $slug.val( text );
        });

        // If it's a select field, listen for the change
        if ($select_slugger.length) {
          $select_slugger.change(function(){
            var text = _this._digestSlug( $sluggers );
            $slug.val( text );
          });

        };
      }
    });
  },

  /**
   * Convert a group of selects or text fields into one slug string
   * @access protected
   * @param {jQuery} $sluggers - Input or inputs that should be converted into a URL-safe string
   * @return {String}
   */
  _digestSlug: function($sluggers) {
    var slug_text = []

    $sluggers.each(function() {
      var $this = $(this);

      if ($this.val().length) {

        if ($this.is('input')) {
          slug_text.push( $this.val() );

        } else {
          slug_text.push( $this.find('option:selected').text() );

        }
      }
    });

    // Combine all active slug fields for the query
    slug_text = slug_text.join(' ');

    // Strip accented characters
    var from = 'âàáâãäæåçèéêëęēėìíîïñòóôõöùúûüýÿÀÁÂÃÄÇÈÉÊËÌÍÎÏÑÒÓÔÕÖÙÚÛÜÝ';
    var to = 'aaaaaaaaceeeeeeeiiiinooooouuuuyyAAAAACEEEEIIIINOOOOOUUUUY';

    // Loop through all accented characters and replace with non-accents
    for (var i = 0; i < from.length; i++) {
      slug_text = slug_text.replace( new RegExp(from.charAt(i), 'g'), to.charAt(i) );
    }

    // Remove leading and trailing spaces
    // Make them lowercase
    // Remove slashes, quotes or periods
    // Replace white spaces with the configured slug separator
    // Remove leading and trailing separators
    var separator = Fae.slugSeparator;
    var escaped_separator = separator.replace(/[.*+?^${}()|[\]\\\-]/g, '\\$&');

    slug_text = slug_text
      .trim()
      .toLowerCase()
      .replace(new RegExp('[^' + escaped_separator + '\\w\\s]', 'g'), '')
      .replace(new RegExp('[' + escaped_separator + '\\s]+', 'g'), function() { return separator; })
      .replace(new RegExp('(^' + escaped_separator + ')|(' + escaped_separator + '$)', 'g'), '');

    return slug_text;
  }

};
