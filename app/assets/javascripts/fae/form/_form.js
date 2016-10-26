/* global Fae */

/**
 * Fae form
 * @namespace form
 * @memberof Fae
 */
Fae.form = {
  ready: function() {
    this.dates.init();
    this.text.init();
    this.select.init();
    this.checkbox.init();
    this.validator.init();
    this.cancel.init();
    this.ajax.init();
    this.filtering.init();
    this.slugger.init();

    // input type=file customization
    // This doesn't work in IE. It's not worth figuring out why by this point. IE9 gets plain file uploader.
    if (!FCH.IE9) {
      $('.input.file').fileinputer();
    }

    // Mutate DOM to support two column labels for all standard inputs
    // @note This is done via JS because making these modifications via simple_form requires a deep dive
    this.make_two_column_labels();

    // make all the hint areas
    $('.hint').hinter();
  },

  make_two_column_labels: function() {
    $('.input label').each(function() {
      var $element = $(this);

      // Otherwise, check for presence of helper_text
      if ($element.find('.helper_text').length) {

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
      }
    });
  }
};
