/* global Fae, datepicker */

'use strict';

Fae.form.checkbox = {

  init: function() {
    this.loginCheckbox();
    this.setCheckboxAsActive();
  },

  loginCheckbox: function() {
    // Login page checkbox
    $(".login-body").on('click', 'label.boolean', function(e){
      $(this).toggleClass("js-active");
    }).on('click', '.input.boolean :checkbox', function(e){
      e.stopPropagation();
    });
  },

  setCheckboxAsActive: function() {
    // Run through the checkboxes and see if they are checked. apply js class for styling.
    $('.boolean label, .checkbox_collection--vertical label, .checkbox_collection--horizontal label').each(function(){
      if ($(this).find(":checkbox:checked").length > 0) {
        $(this).addClass("js-active");
      }
    });
  }
};
