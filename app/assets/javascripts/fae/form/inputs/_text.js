/* global Fae */

'use strict';

Fae.form.text = {

  init: function() {
    this.slugger();
  },


  slugger: function() {
    var $form = $('.slug').closest('form');
    var $sluggers = $form.find('.slugger');
    var $slug = $form.find('.slug');
    var $select_slugger = $('.select.slugger');
    var _this = this;

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
  },

  // Convert a group of selects or text fields into one slug string
  // returns {String}
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
    // Make them lowercase
    // Remove slashes, quotes or periods
    // Replace white spaces with a dash
    // Remove leading and trailing dashes
    slug_text = slug_text
      .join(' ')
      .toLowerCase()
      .replace(/(\\)|(\')|(\.)/g, '')
      .replace(/[^a-zA-Z0-9]+/g, '-')
      .replace(/(-$)|(^-)/g, '');

    return slug_text;
  },

};
