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

    // make all the hint areas
    $('.hint').hinter();
  },

};
