/* global Fae */

/**
 * Fae form checkbox
 * @namespace form.checkbox
 * @memberof form
 */
Fae.form.checkbox = {

  init: function() {
    this.setCheckboxAsActive();
  },

  /**
   * Run through the checkboxes and see if they are checked. apply js class for styling.
   */
  setCheckboxAsActive: function() {
    $('.boolean label, .js-checkbox-wrapper label').each(function(){
      var $this = $(this);

      if ($this.find(':checkbox:checked').length) {
        $this.addClass('active');
      }
    });
  }

};
