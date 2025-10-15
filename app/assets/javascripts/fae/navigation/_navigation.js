/* global Fae, FCH */

/**
 * Fae navigation
 * @namespace navigation
 * @memberof Fae
 */
Fae.navigation = {

  ready: function() {
    var _this = this;
    
    // Use setTimeout to ensure DOM is fully loaded and flash messages are rendered
    setTimeout(function() {
      _this.showToasts();
    }, 100);
    
    // this.fadeNotices();
    this.openDrawer();
    this.clickBack();
    this.accordionClickEventListener();

    this.language.init();
    this.subnav_highlighter.init();
    this.global_search.init();
  },

  load: function() {
    this.stickyHeaders();
    this.lockFooter();
  },

  resize: function() {
    this.closeAll(false);
    this.lockFooter();
  },

  /**
   * Attach click listener to main and sub links
   * @has_test {features/nav_spec.rb}
   */
  accordionClickEventListener: function() {
    var _this = this;

    $('.js-accordion > a').click(function(e) {
      e.preventDefault();

      var $parent = $(this).closest('.js-accordion');
      var was_open = $parent.hasClass('-open');

      // close all first
      // only get the first class name and add a leading period
      $parent.siblings().each(function() {
        _this.close($(this));
      });

      if (was_open) {
        var $sub_accordions = $parent.find('.js-accordion');

        // Close all nested accordions
        if($sub_accordions.length) {
          $sub_accordions.each(function() {
            _this.close($(this));
          });
        }

        // Close original accordion
        _this.close($parent);

      } else {
        // open the clicked item if it was not just opened
        _this.open($parent);
      }

    });
  },

  /**
   * Open accordion panel
   * @protected
   * @param {jQuery} $el - Accordion wrapper
   */
  open: function($el) {
    $el.addClass('-open');

    if(FCH.bp.large) {
      $el.find('.js-subnav').first().stop().slideDown();
    }
  },

  /**
   * Close accordion panel
   * @protected
   * @param {jQuery} $el - Accordion wrapper
   */
  close: function($el) {
    if(FCH.bp.large) {
      $el.find('.js-subnav')
        .first()
        .stop()
        .slideUp()
        .queue(function() {
          // Remove class after animation
          $el.removeClass('-open');
          $.dequeue( this );
        });
    } else {
      $el.removeClass('-open');
    }
  },

  /**
   * Close main level navs
   * @param {Boolean} nuclear - Slide up drawers too
   * @see  {@link resize}
   * @see  {@link openDrawer}
   */
  closeAll: function(nuclear) {
    var _this = this;
    $('html').removeClass( 'mobile-active' );

    $('.js-accordion').each(function(){
      var $this = $(this);

      $this.removeClass('-open');

      if(nuclear) {
        _this.close( $this );
      }
    });
  },

  /**
   * Mobile - Push body over and display nav
   */
  openDrawer: function() {
    var $html = $('html');

    $('#js-mobilenav-toggle').click(function(e){
      e.preventDefault();

      if ($html.hasClass( 'mobile-active' )) {
        Fae.navigation.closeAll(true);
      } else {
        $html.addClass( 'mobile-active' );
      }
    });
  },

  /**
   * Mobile - Collapse sub headers on sub nav click
   */
  clickBack: function() {
    $('.js-mobile-back').click(function(e){
      e.preventDefault();

      $(this)
        .closest('.js-accordion')
        .removeClass('-open');
    });
  },

  /**
   * Hide main-page alerts after 3 seconds
   */
  fadeNotices: function() {
    $('.notice, .alert, .error, .warning').not('.input .error, .form_alert').delay(3000).slideUp('fast');
    // Handle toast notifications
    this.showToasts();
  },

  /**
   * Hide alerts immediately
   */
  killNotices: function() {
    $('.notice, .alert, .error, .warning').not('.input .error, .form_alert').hide();
    // Also hide any existing toasts
    $('.flash-toast').removeClass('show').addClass('hide');
  },

  /**
   * Show toast notifications
   */
  showToasts: function() {
    var _this = this;
    
    // Create toast container if it doesn't exist
    if (!$('.toast-container').length) {
      $('body').append('<div class="toast-container"></div>');
    }
    
    var $container = $('.toast-container');
    
    // Clear any existing toasts first
    $container.find('.flash-toast').remove();
    
    var $flashToasts = $('.flash-toast');
    
    // If no flash toasts found, return early
    if (!$flashToasts.length) {
      return;
    }
    
    // Process each flash toast
    $flashToasts.each(function(index) {
      var $toast = $(this);
      var message = $toast.data('message');
      var type = $toast.attr('class').replace('flash-toast', '').trim();
      
      if (message && message.length > 0) {
        // Create toast element
        var $toastElement = $('<div class="flash-toast ' + type + '">' + message + '</div>');
        
        // Add to container
        $container.append($toastElement);
        
        // Show toast with delay for staggered effect
        setTimeout(function() {
          $toastElement.addClass('show');
        }, index * 100);
        
        // Auto-hide after 5 seconds
        setTimeout(function() {
          _this.hideToast($toastElement);
        }, 5000 + (index * 100));
      }
      
      // Remove the original flash-toast element
      $toast.remove();
    });
  },

  /**
   * Hide a specific toast
   */
  hideToast: function($toast) {
    $toast.removeClass('show').addClass('hide');
    
    // Remove from DOM after animation
    setTimeout(function() {
      $toast.remove();
    }, 300);
  },

  /**
   * Stick the header in the content area
   * @param {Boolean} [just_headers=false] Only initialize stickiness for `.js-content-header`
   */
  stickyHeaders: function(just_headers) {
    just_headers = FCH.setDefault(just_headers, false);

    var $header = $('.js-content-header');
    var sidebar_top_offset = (parseInt( $header.outerHeight(), 10) + 30) + 'px';
    $('#js-sidenav').css('padding-top', sidebar_top_offset );

    $header.sticky({
      placeholder: true,
      perpetual_placeholder: true,
      ignore_placeholder_offsets: true
    });

    if (!just_headers) {
      $('#js-sidenav').sticky();
    }
  },

  /**
   * Fix footer to bottom of screen if viewport extends beyond content. Display after calculation has been performed
   */
  lockFooter: function() {
    if(FCH.exists('#js-footer')) {
      var $footer = $('#js-footer');

      // Reset
      $footer.removeClass('active');

      // Lock or unlock
      if ($footer.offset().top < (FCH.dimensions.wh - $footer.outerHeight()) ) {
        $footer.addClass('-locked');
      } else {
        $footer.removeClass('-locked');
      }

      $footer.addClass('active');
    }
  }

};
