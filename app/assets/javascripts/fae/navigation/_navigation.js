/* global Fae, FCH */

/**
 * Fae navigation
 * @namespace navigation
 * @memberof Fae
 */
Fae.navigation = {

  ready: function() {
    this.fadeNotices();
    this.openDrawer();
    this.clickBack();
    this.accordionClickEventListener();

    this.language.init();
    this.subnav_highlighter.init();
    this.global_search.init();
    this.peek.init();
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
  },

  /**
   * Stick the header in the content area
   * @param {Boolean} [just_headers=false] Only initialize stickiness for `.js-content-header`
   */
  stickyHeaders: function(just_headers) {
    just_headers = FCH.setDefault(just_headers, false);

    if(FCH.exists('.js-content-header')) {
      var $header = $('.js-content-header');
      var sidebar_top_offset = (parseInt( $header.outerHeight(), 10) + 30) + 'px';
      $('#js-sidenav').css('padding-top', sidebar_top_offset );

      $header.sticky({
        placeholder: true,
        perpetual_placeholder: true,
        ignore_placeholder_offsets: true
      });

    // @depreciation - remove else block in 2.0
    } else {
      var $header = $('.main_content-header');
      var sidebar_top_offset = (parseInt( $header.outerHeight(), 10) + 30) + 'px';
      $('#js-sidenav').css('padding-top', sidebar_top_offset );

      $('.main_content-header').sticky({
        placeholder: true
      });
    }

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
