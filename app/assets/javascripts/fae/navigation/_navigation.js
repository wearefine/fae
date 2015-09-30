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
    var regex = new RegExp("^" + Fae.path + "\/#?(\\w*)?\/");
    var regex_match = current_base_url.match(regex);
    $('#main_nav a').each(function(){
      var $this = $(this);
      var link = $this.attr('href');
      if ((regex_match !== null && regex_match.length && link.indexOf(regex_match[1]) > -1) || link === current_base_url) {
        $this.addClass('current');
      }
    });

    _this._updateNavClasses();
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
