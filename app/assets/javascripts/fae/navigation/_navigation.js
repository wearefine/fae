/* global Fae, FCH */

'use strict';

/**
 * Fae navigation
 * @namespace navigation
 * @memberof Fae
 */
Fae.navigation = {

  init: function() {
    this.selectCurrentNavItem();
    this.fadeNotices();
    this.stickyHeaders();
    this.subnavHighlighter.init();
    this.openDrawer();
    this.clickBack();
    this.language.init();
    this.accordionClickEventListener();
    this.utilitySearch();
    this.typeaheadSearch();
  },

  resize: function() {
    this.closeAll(false);
  },

  /**
   * Set nested links to be current in the nav
   * @fires {@link navigation._updateNavClasses}
   */
  selectCurrentNavItem: function() {
    var current_base_url = window.location.pathname.replace('#', '');
    var $ready_current_link = $('.js-nav a[href="' + current_base_url + '"]');

    /**
     * Apply current nav class or keep looking deeper from path for the answer
     * @private
     * @param {String} mutated_url - The remaining URL to be checked
     * @return {Function} or add class
     */
    function findCurrentNavRecursively(mutated_url) {
      // Remove last element of URL
      var url_array = mutated_url.split('/');
      url_array.pop();
      mutated_url = url_array.join('/');

      var $current_link = $('.js-nav a[href="' + mutated_url + '"]');
      if ($current_link.length) {
        $current_link.addClass('-current');

      } else {
        // Defend from exceeding call stack (SUPER RECURSION)
        if (url_array.length) {
          // If it can't be found, start over and try again
          findCurrentNavRecursively(mutated_url);
        }
      }
    }

    if ($ready_current_link.length) {
      // Try to find link that matches the URL exactly
      $ready_current_link.addClass('-current');

    } else {
      // If link can't be found, recursively search for it
      findCurrentNavRecursively(current_base_url);

    }

    $('.js-accordion, .js-main-header-parent').each(function() {
      var $this = $(this);

      if($this.find('.-current').length) {
        $this.addClass('-current');

        if(FCH.bp.large && $this.hasClass('.js-accordion')) {
          $this.addClass('-open');
        }
      }
    });
  },

  /**
   * Attach click listener to main and sub links
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
   * Click event of the admin search in the main nav
   */
  utilitySearch: function() {

    $('#js-utility-search').click(function(e) {
      e.preventDefault();
      e.stopPropagation();

      var $this = $(this);
      var $search_wrapper = $this.find('.utility-search-wrapper');

      $search_wrapper.toggle();

      if($search_wrapper.is(':visible')) {
        $this.find('input').focus();
      }

    });
  },

  /**
   * Initialize the typeahead navigation in the header nav
   */
  typeaheadSearch: function() {
    function onTypeaheadSelected(ev, data) {
      window.location.href = data.path;
    }

    function onTypeaheadFocused() {
      $(this).attr('placeholder', '');
    }

    function onTypeaheadBlur() {
      if($(this).val() === '') {
        $(this).attr('placeholder', 'Jump to...');
      }
    }

    var sample_data = [
      {
        fae_display_field: 'Releases'
      },
      {
        fae_display_field: 'Wines'
      },
      {
        fae_display_field: 'Coaches'
      }
    ];

    var models = new Bloodhound({
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace('fae_display_field'),
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      // prefetch: {
      //   url: '/data/models.json',
      //   ttl: 60000
      // }
      local: sample_data
    });
    models.initialize();

    $('#js-search').typeahead(
      {
        hint: true,
        highlight: true,
        minLength: 2,
        autoselect: true
      },
      {
        name: 'models',
        displayKey: 'fae_display_field',
        source: models.ttAdapter()
      }
    )
    .on('typeahead:selected', onTypeaheadSelected)
    .on('typeahead:focused', onTypeaheadFocused)
    .on('typeahead:blur', onTypeaheadBlur);
  },

  /**
   * Hide main-page alerts after 3 seconds
   */
  fadeNotices: function() {
    $('.notice, .alert, .error').not('.input .error, .form_alert').delay(3000).slideUp('fast');
  },

  /**
   * Stick the header in the content area
   * @param {Boolean} [just_headers=false] Only initialize stickiness for `.js-content-header`
   */
  stickyHeaders: function(just_headers) {
    just_headers = FCH.setDefault(just_headers, false);

    if(FCH.exists('.js-content-header')) {
      var $header = $('.js-content-header');
      var sidebar_top_offset = (parseInt( $header.css('height'), 10) + 20) + 'px';
      $('#js-sidenav').css('padding-top',  sidebar_top_offset );

      $header.sticky({
        placeholder: true,
        perpetual_placeholder: true
      });
    } else {
      $('.main_content-header').sticky({
        placeholder: true
      });
    }

    if(!just_headers) {
      $('#js-sidenav').sticky();
    }
  },

};
