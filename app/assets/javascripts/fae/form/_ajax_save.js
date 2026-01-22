/* global Fae, FCH */

/**
 * Fae AJAX Save
 * Handles AJAX form submission for main forms (create/edit)
 * Redraws the form after save to ensure all dynamic elements are in sync
 * @namespace form.ajaxSave
 * @memberof form
 */
Fae.form.ajaxSave = {

  // Flag to prevent double submissions
  isSubmitting: false,

  init: function() {
    this.bindMainFormSubmission();
  },

  /**
   * Bind AJAX submission to main content forms
   * Targets forms that contain main.content (the standard Fae form structure)
   */
  bindMainFormSubmission: function() {
    var _this = this;

    // Target forms that wrap main.content - these are the main edit/create forms
    $(document).on('submit', 'form:has(main.content)', function(ev) {
      var $form = $(this);

      // Skip if form has data-ajax-save="false" to allow opt-out
      if ($form.data('ajax-save') === false) {
        return true;
      }

      // Skip if this is a nested form or already has remote: true
      if ($form.hasClass('js-file-form') || $form.data('remote') === true) {
        return true;
      }

      // Only proceed with AJAX if the form has passed client-side validation
      // The validator sets this flag after all validations pass
      if ($form.data('passed_validation') !== 'true') {
        // Let the validator handle it first
        return true;
      }

      // Prevent double submissions
      if (_this.isSubmitting) {
        ev.preventDefault();
        return false;
      }

      ev.preventDefault();
      _this.isSubmitting = true;

      var formData = new FormData($form[0]);
      var $submitBtn = $form.find('input[type="submit"], button[type="submit"]').first();
      var originalText = $submitBtn.val() || $submitBtn.text();

      // Show saving state
      $submitBtn.prop('disabled', true).addClass('saving');
      if ($submitBtn.is('input')) {
        $submitBtn.val('Saving...');
      } else {
        $submitBtn.text('Saving...');
      }

      $.ajax({
        url: $form.attr('action'),
        type: $form.attr('method') || 'POST',
        data: formData,
        processData: false,
        contentType: false,
        dataType: 'html',
        headers: {
          'Accept': 'text/javascript, application/javascript'
        },
        success: function(html) {
          _this.handleSuccess(html, $form);
        },
        error: function(xhr, status, error) {
          _this.handleError(xhr, $form, $submitBtn, originalText);
        }
      });
    });
  },

  /**
   * Handle successful form submission
   * Replaces the form with the returned HTML and reinitializes all elements
   * @param {String} html - HTML response from server (the edit form)
   * @param {jQuery} $form - The original form element
   */
  handleSuccess: function(html, $form) {
    var _this = this;
    
    // Save current scroll position before DOM manipulation
    var scrollTop = $(window).scrollTop();

    // Parse the returned HTML
    var $newContent = $(html);

    // Find the new form in the response
    var $newForm = $newContent.filter('form').first();
    if (!$newForm.length) {
      $newForm = $newContent.find('form').first();
    }

    if ($newForm.length) {
      // Replace the entire form
      $form.replaceWith($newForm);

      // Reinitialize all form elements
      _this.reinitializeForm($newForm);

      // Show toast notifications
      Fae.navigation.showToasts();
      
      // Remove draft param from URL after successful save (no longer a draft)
      _this.removeDraftParam();
      
      // Restore scroll position after DOM replacement and reinitialization
      // Use requestAnimationFrame + setTimeout to ensure it happens after 
      // all DOM calculations, layout reflows, and sticky header setup
      requestAnimationFrame(function() {
        setTimeout(function() {
          $(window).scrollTop(scrollTop);
        }, 50);
      });
    } else {
      // Fallback: replace body content if we can't find the form
      var $mainContent = $('#js-main-content');
      if ($mainContent.length && $newContent.length) {
        $mainContent.html($newContent);
        _this.reinitializeForm($mainContent.find('form').first());
        Fae.navigation.showToasts();
        
        // Restore scroll position after DOM replacement
        requestAnimationFrame(function() {
          setTimeout(function() {
            $(window).scrollTop(scrollTop);
          }, 50);
        });
      }
    }

    // Reset submission flag
    _this.isSubmitting = false;
  },

  /**
   * Handle form submission errors
   * @param {Object} xhr - jQuery XHR object
   * @param {jQuery} $form - The form element
   * @param {jQuery} $submitBtn - The submit button
   * @param {String} originalText - Original button text
   */
  handleError: function(xhr, $form, $submitBtn, originalText) {
    // Reset submission flag
    this.isSubmitting = false;

    // If we got HTML back (validation errors), replace the form
    if (xhr.status === 200 || xhr.status === 422) {
      var html = xhr.responseText;
      if (html && html.length > 0) {
        this.handleSuccess(html, $form);
        return;
      }
    }

    // Otherwise just re-enable the button and show an error
    $submitBtn.prop('disabled', false).removeClass('saving');
    if ($submitBtn.is('input')) {
      $submitBtn.val(originalText);
    } else {
      $submitBtn.text(originalText);
    }

    // Show error toast
    this.showToast('An error occurred while saving. Please try again.', 'alert');
  },

  /**
   * Reinitialize all dynamic form elements after replacing HTML
   * @param {jQuery} $form - The new form element
   */
  reinitializeForm: function($form) {
    // Clear validator's passed_validation flag
    $form.data('passed_validation', '');

    // Reinitialize Chosen selects
    $form.find('.select select').fae_chosen();

    // Reinitialize file uploaders
    if (!FCH.IE9) {
      $form.find('.input.file').fileinputer();
    }

    // Reinitialize all form modules
    Fae.form.dates.init();
    Fae.form.dates.initDatepicker();
    Fae.form.dates.initDateRangePicker();
    Fae.form.color.init();
    Fae.form.color.initColorpicker();
    Fae.form.text.init();
    Fae.form.text.initMarkdown();
    Fae.form.text.initHTML();
    Fae.form.select.init();
    Fae.form.checkbox.init();
    Fae.form.checkbox.setCheckboxAsActive();
    Fae.form.slugger.init();
    Fae.form.slugger.addListener();
    Fae.form.formManager.init();
    Fae.form.validator.init();
    Fae.form.validator.length_counter.init();
    
    // Reinitialize AJAX module (for nested tables, component select, etc.)
    Fae.form.ajax.init();
    
    // Reinitialize ranked select
    Fae.form.rankedSelect.init();

    // Reinitialize hints
    $form.find('.hint').hinter();

    // Reinitialize drag/drop and table sorting
    Fae.form.dragDrop.init();
    Fae.tables.rowSorting();

    // Reinitialize navigation elements
    Fae.navigation.stickyHeaders(true);
    Fae.navigation.lockFooter();
    Fae.navigation.subnav_highlighter.init();

    // Check for validation errors and show error bar if present
    this.checkForErrors($form);

    // Reinitialize translation and alt text features
    if (Fae.form.text.initTranslation) {
      Fae.form.text.initTranslation();
    }
    if (Fae.form.text.initGenerateAlt) {
      Fae.form.text.initGenerateAlt();
    }
    if (Fae.altTextManager && Fae.altTextManager.ready) {
      Fae.altTextManager.ready();
    }

    // Rebind validation events
    Fae.form.validator.formValidate();
    Fae.form.validator.bindValidationEvents($form);
  },

  /**
   * Check for validation errors in the form and show error bar if present
   * @param {jQuery} $form - The form element
   */
  checkForErrors: function($form) {
    var hasErrors = $form.find('.field_with_errors').length > 0;
    
    if (hasErrors) {
      // Use the validator's method to build error links if available
      if (Fae.form.validator && Fae.form.validator.checkForSsrImageAndFileErrors) {
        Fae.form.validator.checkForSsrImageAndFileErrors();
      }
      
      // Also check for general field errors and build links
      if (Fae.form.validator && Fae.form.validator._buildErrorLinks) {
        Fae.form.validator._buildErrorLinks();
      }
      
      // Show the error bar
      $('.errors-bar-wrapper').slideDown('fast');
    }
  },

  /**
   */
  showToast: function(message, type) {
    // Create toast container if it doesn't exist
    if (!$('.toast-container').length) {
      $('body').append('<div class="toast-container"></div>');
    }

    var $container = $('.toast-container');
    var $toast = $('<div class="flash-toast ' + type + '">' + message + '</div>');

    $container.append($toast);

    setTimeout(function() {
      $toast.addClass('show');
    }, 10);

    setTimeout(function() {
      if (Fae.navigation && Fae.navigation.hideToast) {
        Fae.navigation.hideToast($toast);
      } else {
        $toast.removeClass('show');
        setTimeout(function() {
          $toast.remove();
        }, 300);
      }
    }, 5000);
  },

  /**
   * Remove draft param from URL after successful save
   * This ensures the cancel button won't delete the record after it's been saved
   */
  removeDraftParam: function() {
    var url = new URL(window.location.href);
    if (url.searchParams.has('draft')) {
      url.searchParams.delete('draft');
      window.history.replaceState(null, null, url.pathname + url.search);
    }
  }

};
