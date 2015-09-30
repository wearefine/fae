/* global Fae, modal, FCH */

'use strict';

/**
 * Fae modals
 * @namespace
 */
Fae.modals = {
  init: function() {
    this.imageModals();
    this.markdownModal();
  },

  /**
   * Click event to open modal with only an image
   */
  imageModals: function() {
    $('.js-image-modal').click(function(e){
      e.preventDefault();
      var $this = $(this);

      // create invisi-image to get natural width/height
      var image = new Image();
      image.src = $this.attr('src');
      var image_width = image.width;
      var image_height = image.height;

      $this.modal({
        minHeight: image_height,
        minWidth: image_width,
        overlayClose: true
      });
    });
  },

  /**
   * Initialize modal for markdown-hint. Triggered on document click of "markdown-support" so as to support AJAX'd markdown-support fields.
   */
  markdownModal: function() {
    FCH.$document.on('click', '.markdown-support', function(){
      var markdown_hint_width = $('.markdown-hint').width() + 40;

      $('.markdown-hint-wrapper').modal({
        minHeight: 430,
        minWidth: markdown_hint_width,
        overlayClose: true,
        zIndex: 1100
      });
    });
  }
};
