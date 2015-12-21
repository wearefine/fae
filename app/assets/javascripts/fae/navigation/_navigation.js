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
    this.utilityNav();
    this.buttonDropdown();
    this.fadeNotices();
    this.stickyHeaders();
    this.subnavHighlighter.init();
    this.mobileMenu.init();
    this.language.init();
    this.accordionClickEventListener();
  },

  /**
   * Set nested links to be current in the nav
   * @fires {@link navigation._updateNavClasses}
   */
  selectCurrentNavItem: function() {
    var _this = this;
    var current_base_url = window.location.pathname.replace('#', '');
    var $currentLink = $('#js-main_nav a[href="' + current_base_url + '"]');

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

      var $currentLink = $('#js-main_nav a[href="' + mutated_url + '"]');
      if ($currentLink.length) {
        $currentLink.addClass('current');

      } else {
        // Defend from exceeding call stack (SUPER RECURSION)
        if (url_array.length) {
          // If it can't be found, start over and try again
          findCurrentNavRecursively(mutated_url);

        }

      }
    }

    if ($currentLink.length) {
      // Try to find link that matches the URL exactly
      $currentLink.addClass('current');

    } else {
      // If link can't be found, recursively search for it
      findCurrentNavRecursively(current_base_url);

    }

    $('#js-main_nav .main_nav-accordion').each(function() {
      if($(this).find('.current').length) {
        $(this).addClass('current');
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

      var $this = $(this);
      var $parent = $this.closest('.js-accordion');
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
    $el.find('.main_nav-sub-nav').first().stop().slideDown();
  },

  /**
   * Close accordion panel
   * @protected
   * @param {jQuery} $el - Accordion wrapper
   */
  close: function($el) {
    $el.removeClass('-open');
    $el.find('.main_nav-sub-nav').first().stop().slideUp();
  },

  /**
   * Utility nav drop down
   */
  utilityNav: function() {
    $('.utility_nav-user > a, .utility_nav-view > a').on('click', function(e) {
      e.preventDefault();
      e.stopPropagation();
      var $sub_nav = $(this);

      // there could be more than one. so remove all of the clicked statuses and add to the specific one
      $('.utility_nav-clicked').removeClass('utility_nav-clicked');
      $sub_nav.addClass('utility_nav-clicked');

      // assign a once function to close the menus
      FCH.$document.on('click.utility_nav', function(e){
        // as long as the click is not in the menu
        if (!$(e.target).closest('.utility_sub_nav').length) {
          // remove the class from the utility nav
          $sub_nav.removeClass('utility_nav-clicked');

          // unbind the click from the document, no need to keep it around.
          FCH.$document.off('click.utility_nav');
        }
      });
    });
  },

  /**
   * Toggle class on button dropdown; close dropdown on click anywhere
   */
  buttonDropdown: function() {
    // button dropdown class toggle
    $('.button-dropdown').click(function(){
      $(this).toggleClass('button-dropdown--opened');
    });

    // button dropdown click anywhere but the dropdown close
    FCH.$document.click(function(e){
      if (!$(e.target).closest('.button-dropdown').length) {
        $('.button-dropdown').removeClass('button-dropdown--opened');
      }
    });
  },

  /**
   * Hide main-page alerts after 3 seconds
   */
  fadeNotices: function() {
    $('.notice, .alert, .error').not('.input .error, .form_alert').delay(3000).slideUp('fast');
  },

  /**
   * Stick the header in the content area
   */
  stickyHeaders: function() {
    $(".main_content-header").sticky();
    $("#js-main_nav").sticky({
      make_placeholder: false
    });
  },

};
