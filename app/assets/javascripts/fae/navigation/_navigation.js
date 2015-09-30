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
    this.accordion.init();
  },

  /**
   * Set nested links to be current in the nav
   * @fires {@link navigation._updateNavClasses}
   */
  selectCurrentNavItem: function() {
    var _this = this;
    var current_base_url = window.location.pathname;
    var $currentLink = $('#main_nav a[href="' + current_base_url + '"]');
    if ($currentLink.length) {
      // Try to find link that matches the URL exactly
      $currentLink.addClass('current');

    } else {
      // If link can't be found, recursively search for it
      this._findCurrentNavRecursively(current_base_url);

    }

    _this._updateNavClasses();
  },

  /**
   * Apply current nav class or keep looking deeper from path for the answer
   * @access protected
   * @param {String} mutated_url - The remaining URL to be checked
   * @return {Function} or add class
   */
  _findCurrentNavRecursively: function(mutated_url) {
    // Remove last element of URL
    var url_array = mutated_url.split('/');
    url_array.pop();
    mutated_url = url_array.join('/');
    console.log(mutated_url);
    var $currentLink = $('#main_nav a[href="' + mutated_url + '"]');
    if ($currentLink.length) {
      $currentLink.addClass('current');

    } else {
      // If it can't be found, start over and try again
      this._findCurrentNavRecursively(mutated_url);

    }
  },

  /**
   * Set nested links to be current in the nav
   * @access protected
   */
  _updateNavClasses: function() {
    $('#main_nav a.current').each(function() {
      var $this = $(this);

      if ($this.hasClass('main_nav-link')) {
        $this.closest('li').addClass('main_nav-active-single');

      } else if ($this.hasClass('main_nav-sub-link')) {
        $this
          .closest('li').addClass('main_nav-sub-active')
          .closest('.main_nav-accordion').removeClass('main_nav-accordion').addClass('main_nav-active');

      } else if ($this.hasClass('main_nav-third-link')) {
        $this
          .closest('li').addClass('main_nav-third-active')
          .closest('.sub_nav-accordion').removeClass('sub_nav-accordion').addClass('main_nav-sub-active--no_highlight')
          .closest('.main_nav-accordion').removeClass('main_nav-accordion').addClass('main_nav-active');

      }
    });
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
    $('.notice, .alert, .error').not('.input .error').delay(3000).slideUp('fast');
  },

  /**
   * Stick the header in the content area
   */
  stickyHeaders: function() {
    $(".main_content-header").sticky();
    $("#main_nav").sticky({
      make_placeholder: false
    });
  },

};
