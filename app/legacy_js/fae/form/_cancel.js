/* global Fae */

/**
 * Fae form cancel
 * @namespace form.cancel
 * @memberof form
 */
Fae.form.cancel = {

  init: function() {
    // handled by the fae-cancel Stimulus controller
    if ($('#js-header-cancel').is('[data-controller~="fae-cancel"]')) {
      return;
    }

    this.detectCancelledUrls();
    this.addCancelParam();
    this.handleDraftCancel();
    this.handleDraftBeforeUnload();
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
      var href = $cancel_btn.attr('href');

      if (href && href.indexOf('cancelled=true') === -1) {
        $cancel_btn.attr('href', href + '?cancelled=true');
      }
      $('form').off('change', 'input, textarea, select', updateCancel);
    }

    Fae.fresh($('form'), 'cancel-param').on('change', 'input, textarea, select', updateCancel);
  },

  /**
   * Handle cancel button click for draft records - confirm and delete if user agrees
   */
  handleDraftCancel: function() {
    var $cancel_btn = Fae.fresh($('#js-header-cancel'), 'draft-cancel');
    var isDraft = $cancel_btn.attr('data-draft');
    
    // Check for string 'true' (data attributes are always strings via attr())
    if (isDraft !== 'true') {
      return;
    }
    
    var deletePath = $cancel_btn.attr('data-delete-path');
    var indexPath = $cancel_btn.attr('href').split('?')[0];

    // If we have a delete path, set up the link to use rails-ujs DELETE method
    if (deletePath && deletePath.length > 0) {
      $cancel_btn.attr('href', deletePath);
      $cancel_btn.attr('data-method', 'delete');
      // Store the index path to redirect to after delete
      $cancel_btn.attr('data-index-path', indexPath);
    }

    $cancel_btn.on('click', function(e) {
      if (!confirm('You will lose any changes to this draft. Are you sure you want to cancel?')) {
        e.preventDefault();
        e.stopPropagation();
        return false;
      }
      // User confirmed cancellation - allow navigation without beforeunload warning
      Fae.form.cancel.allowUnload = true;
      // If confirmed, let rails-ujs handle the DELETE via data-method
      // The controller should redirect to index after destroy
    });
  },

  /**
   * Warn users when navigating away from a draft form (closing tab, clicking links, etc.)
   */
  handleDraftBeforeUnload: function() {
    var $cancel_btn = Fae.fresh($('#js-header-cancel'), 'draft-unload');
    var isDraft = $cancel_btn.attr('data-draft');

    // Only apply to draft forms
    if (isDraft !== 'true') {
      return;
    }

    // Track if we should allow unload (set when user confirms via cancel button or form submit)
    this.allowUnload = false;

    // Allow unload on successful form submission
    Fae.fresh($('form'), 'draft-unload-submit').on('submit', function() {
      Fae.form.cancel.allowUnload = true;
    });

    // One window listener for the life of the document; it only acts while a draft form is on screen
    Fae.once('cancel-beforeunload', function() {
      window.addEventListener('beforeunload', function(e) {
        if (Fae.form.cancel.allowUnload || $('#js-header-cancel').attr('data-draft') !== 'true') {
          return;
        }

        // Standard way to trigger the browser's confirmation dialog
        e.preventDefault();
        e.returnValue = '';
      });
    });
  }

};
