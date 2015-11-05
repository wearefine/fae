/* global Fae, SimpleMDE, toolbarBuiltInButtons */

'use strict';

/**
 * Fae form text
 * @namespace form.text
 * @memberof form
 */
Fae.form.text = {

  init: function() {
    this.slugger();
    this.overrideMarkdownDefaults();
    this.initMarkdown();
  },

  /**
   * Attach listeners to inputs and update slug fields with original safe values from the original inputs
   */
  slugger: function() {
    var _this = this;

    $('.slug').each(function() {
      var $form = $(this).closest('form');
      var $sluggers = $form.find('.slugger');
      var $slug = $form.find('.slug');
      var $select_slugger = $('.select.slugger');

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

  /**
   * Override SimpleMDE's preference for font-awesome icons and use a modal for the guide
   * @see {@link modals.markdownModal}
   */
  overrideMarkdownDefaults: function() {
    toolbarBuiltInButtons['bold'].className = 'icon-bold';
    toolbarBuiltInButtons['italic'].className = 'icon-italic';
    toolbarBuiltInButtons['heading'].className = 'icon-font';
    toolbarBuiltInButtons['code'].className = 'icon-code';
    toolbarBuiltInButtons['unordered-list'].className = 'icon-list-ul';
    toolbarBuiltInButtons['ordered-list'].className = 'icon-list-ol';
    toolbarBuiltInButtons['link'].className = 'icon-link';
    toolbarBuiltInButtons['image'].className = 'icon-image';
    toolbarBuiltInButtons['quote'].className = 'icon-quote';
    toolbarBuiltInButtons['fullscreen'].className = 'icon-fullscreen no-disable no-mobile';
    toolbarBuiltInButtons['horizontal-rule'].className = 'icon-minus';
    toolbarBuiltInButtons['preview'].className = 'icon-eye no-disable';
    toolbarBuiltInButtons['side-by-side'].className = 'icon-columns no-disable no-mobile';
    toolbarBuiltInButtons['guide'].className = 'icon-question';

    // Override SimpleMDE's default guide and use a homegrown modal
    toolbarBuiltInButtons['guide'].action = Fae.modals.markdownModal;
  },

  /**
   * Find all markdown fields and initialize them with a markdown GUI
   * @has_test {features/form_helpers/fae_input_spec.rb}
   */
  initMarkdown: function() {
    var fields = document.getElementsByClassName('js-markdown-editor');

    for(var i = 0; i < fields.length; i++) {
      var editor = new SimpleMDE({
        element: fields[i],
        autoDownloadFontAwesome: false,
        status: false,
        spellChecker: false,
        hideIcons: ['image', 'side-by-side', 'fullscreen', 'preview']
      });
    }
  }

};
