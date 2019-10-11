/* global Fae */

/**
 * Fae form
 * @namespace form
 * @memberof Fae
 */
Fae.form = {
  ready: function() {
    // Mutate DOM to support two column labels for all standard inputs
    this.makeTwoColumnLabels();

    this.dates.init();
    this.color.init();
    this.text.init();
    this.select.init();
    this.checkbox.init();
    this.validator.init();
    this.cancel.init();
    this.ajax.init();
    this.filtering.init();
    this.slugger.init();
    this.formManager.init();

    // input type=file customization
    // This doesn't work in IE. It's not worth figuring out why by this point. IE9 gets plain file uploader.
    if (!FCH.IE9) {
      $('.input.file').fileinputer();
    }

    // make all the hint areas
    $('.hint').hinter();
  },

  makeTwoColumnLabels: function() {
    $('.input label').each(function() {
      var $element = $(this);

      // Bail if we cannot find any helper_text
      if (!$element.find('.helper_text').length) {
        $element.addClass('has_no_helper_text');
      }

      // If present, get all DOM nodes w/ contents(), but ignore the .helper_text
      var label_inner = $element.contents().filter(function() {
        return !$(this).hasClass('helper_text');
      });
      var helper_text = $element.find('.helper_text');

      // Replace existing label w/ newly wrapped elements, sans .helper_text
      label_inner = $('<div class="label_inner" />').html(label_inner);
      $element.html(label_inner);

      // But then add .helper_text as a sibling
      $element.append(helper_text);

      // Ensure that we mark this input as having two column label support
      $element.addClass('label--two_col');
    });
  }
};
