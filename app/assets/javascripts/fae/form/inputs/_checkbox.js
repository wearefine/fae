/* global Fae */

'use strict';

/**
 * Fae form checkbox
 * @namespace
 */
Fae.form.checkbox = {

  init: function() {
    this.loginCheckbox();
    this.setCheckboxAsActive();
  },

  /**
   * @public
   * @description Login page checkbox listeners to add active class on click
   */
  loginCheckbox: function() {
    $('.login-body')
      .on('click', 'label.boolean', function(e){
        $(this).toggleClass('js-active');
      })
      .on('click', '.input.boolean :checkbox', function(e){
        e.stopPropagation();
      });
  },

  /**
   * @public
   * @description Run through the checkboxes and see if they are checked. apply js class for styling.
   */
  setCheckboxAsActive: function() {
    $('.boolean label, .checkbox_collection--vertical label, .checkbox_collection--horizontal label').each(function(){
      var $this = $(this);

      if ($this.find(':checkbox:checked').length) {
        $this.addClass('js-active');
      }
    });
  }
};
