/* global Fae */

'use strict';

/**
 * Fae form
 * @namespace form
 * @memberof Fae
 */
Fae.form = {
  init: function() {
    this.dates.init();
    this.text.init();
    this.select.init();
    this.checkbox.init();
    this.validator.init();
    this.cancel.init();
    this.ajax.init();

    // input type=file customization
    $('.input.file').fileinputer({delete_class: 'icon-delete_x file_input-delete'});

    // make all the hint areas
    $('.hint').hinter();
  },

};
