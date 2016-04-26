/* global Fae */

/**
 * Fae form checkbox
 * @namespace form.checkbox
 * @memberof form
 */
Fae.form.checkbox = {

  init: function() {
    this.loginCheckbox();
    this.setCheckboxAsActive();
  },

  /**
   * Login page checkbox listeners to add active class on click
   */
  loginCheckbox: function() {
    $('.login-body')
      .on('click', 'label.boolean', function(e){
        $(this).toggleClass('active');
      })
      .on('click', '.input.boolean :checkbox', function(e){
        e.stopPropagation();
      });
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
