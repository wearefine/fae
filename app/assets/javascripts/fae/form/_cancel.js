/* global Fae */

/**
 * Fae form cancel
 * @namespace form.cancel
 * @memberof form
 */
Fae.form.cancel = {

  init: function() {
    this.detectCancelledUrls();
    this.addCancelParam();
    this.handleDraftCancel();
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
  },

  /**
   * Handle cancel button click for draft records - confirm and delete if user agrees
   */
  handleDraftCancel: function() {
    var $cancel_btn = $('#js-header-cancel');
    var isDraft = $cancel_btn.data('draft');
    
    // Check for both boolean true and string 'true'
    if (isDraft !== true && isDraft !== 'true') {
      return;
    }

    $cancel_btn.on('click', function(e) {
      e.preventDefault();
      
      var deletePath = $cancel_btn.data('delete-path');
      var indexPath = $cancel_btn.attr('href').split('?')[0]; // Remove any query params
      
      if (confirm('You will lose any changes to this draft. Are you sure you want to cancel?')) {
        if (deletePath) {
          $.ajax({
            url: deletePath,
            type: 'DELETE',
            success: function() {
              window.location.href = indexPath;
            },
            error: function() {
              // If delete fails, still navigate away
              window.location.href = indexPath;
            }
          });
        } else {
          window.location.href = indexPath;
        }
      }
    });
  }

};
