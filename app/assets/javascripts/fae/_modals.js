/* global Fae, modal, FCH */

/**
 * Fae modals
 * @namespace
 */
Fae.modals = {
  ready: function() {
    this.imageModals();
    this.markdownModalListener();
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
      var image_width = image.width + 55;
      var image_height = image.height + 55;

      $this.modal({
        minHeight: image_height,
        minWidth: image_width,
        overlayClose: true
      });
    });
  },

  /**
   * Display markdown guide in a modal
   * @see {@link form.text.overrideMarkdownDefaults}
   * @see {@link modals.markdownModalListener}
   * @has_test {features/form_helpers/fae_input_spec.rb}
   */
  markdownModal: function() {
    var markdown_hint_width = $('.markdown-hint').width() + 40;

    $('.markdown-hint-wrapper').modal({
      minHeight: 430,
      minWidth: markdown_hint_width,
      overlayClose: true,
      zIndex: 1100
    });
  },

  /**
   * Markdown guide shown on document click of "markdown-support" so as to support AJAX'd markdown-support fields.
   * @fires {@link modals.markdownModal}
   * @has_test {features/form_helpers/fae_input_spec.rb}
   */
  markdownModalListener: function() {
    FCH.$document.on('click', '.markdown-support', this.markdownModal);
  }
};
