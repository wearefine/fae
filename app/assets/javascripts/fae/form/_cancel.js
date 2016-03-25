/* global Fae */

'use strict';

/**
 * Fae form cancel
 * @namespace form.cancel
 * @memberof form
 */
Fae.form.cancel = {

  init: function() {
    this.detectCancelledUrls();
    this.addCancelParam();
  },

  /**
   * If URL has cancelled param, update the history
   */
  detectCancelledUrls: function() {
    var params = window.location.search;
    if (params.length && params.toLowerCase().indexOf("cancelled") >= 0 && params.indexOf("&") !== 0) {
      window.history.replaceState(null, null, window.location.pathname);
    };
  },

  /**
   * Once any field changes, add cancelled param to button to ensure user knows data will be lost
   */
  addCancelParam: function() {
    function updateCancel() {
      var $cancel_btn = $('#js-header-cancel');
      var new_href = $cancel_btn.attr('href') + '?cancelled=true';
      $cancel_btn.attr('href', new_href);
      $('form').off('change', 'input, textarea, select', updateCancel);
    }

    $('form').on('change', 'input, textarea, select', updateCancel);
  }
};
