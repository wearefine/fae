/* global Fae */

Fae.form.cancel = {

  init: function() {
    this.detect_cancelled_urls();
    this.add_cancel_param();
  },

  detect_cancelled_urls: function() {
    var params = window.location.search;
    if (params.length > 0 && params.toLowerCase().indexOf("cancelled") >= 0 && params.indexOf("&") !== 0) {
      window.history.replaceState(null, null, window.location.pathname);
    };
  },

  add_cancel_param: function() {
    var update_cancel = function () {
      var $cancel_btn = $('#main_content-header-save-cancel');
      var new_href = $cancel_btn.attr('href') + '?cancelled=true';
      $cancel_btn.attr('href', new_href);
      $('form').off('change', 'input, textarea, select', update_cancel);
    }

    $('form').on('change', 'input, textarea, select', update_cancel);
  }
};
