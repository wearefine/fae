/* globals Fae, FCH */

'use strict';

/**
 * Fae navigation mobile menu
 * @namespace navigation.mobileMenu
 * @memberof navigation
 */
Fae.navigation.mobileMenu = {
  toggle_class: 'js-menu-active',
  toggle_level_class: 'js-menu-level-active',
  sub_toggle_level_class: 'js-sub-menu-level-active',

  init: function(){
    this.openDrawer();
    this.mainHeaderClickListener();
    this.resizer();
    this.subMainHeaderClickListener();
    this.thirdNavClickListener();
  },

  /**
   * Check to see if the html has the toggle class...which means it's opened
   */
  openDrawer: function() {
    var _this = this;

    $('#main_nav-menu_button').click(function(e){
      e.preventDefault();

      if (FCH.$html.hasClass(_this.toggle_class)) {
        _this.closeAll();
      } else {
        FCH.$html.addClass(_this.toggle_class);
      }
    });
  },

  /**
   * Close all open drawers
   */
  closeAll: function() {
    // remove the HTML class which closes the first level
    FCH.$html.removeClass(this.toggle_class);

    // remove toggle_level_class and sub_toggle_level_class classes
    $('.' + this.toggle_level_class).removeClass(this.toggle_level_class);
    $('.' + this.sub_toggle_level_class).removeClass(this.sub_toggle_level_class);
  },

  /**
   * Close menus if clicked on actual link. If element does not have sublinks, go to desired page.
   */
  mainHeaderClickListener: function() {
    var _this = this;

    $('#js-main_nav a').click(function(e){
      var $this = $(this);
      var $parent = $this.closest('li');

      // // If element has sublinks
      // if( $this.next() ) {
      //   e.preventDefault()

      //   _this.closeAll();

      //   $parent.addClass(_this.toggle_level_class);
      // }

      if (!$this.hasClass('js-menu-header-active') && FCH.bp.large_down) {
        e.preventDefault();

        var link_url = $this.data('link');

        // Add JS toggle class
        $parent.addClass(_this.toggle_level_class);

        // If the element does not have sublinks, then go to the desired page
        if ($parent.find('.main_nav-sub-nav').length === 0 && typeof link_url !== 'undefined') {
          location.href = link_url;
        }
      }
    });
  },

  /**
   * For ultra deep navs, collapse parent
   */
  thirdNavClickListener: function() {
    var _this = this;

    $('.main_nav-sub-link.with-third_nav').click(function(e){
      if (FCH.bp.large_down) {
        e.preventDefault();
        e.stopImmediatePropagation();
        $(this).parent().addClass(_this.sub_toggle_level_class);
      }
    });
  },

  /**
   * Collapse sub headers on sub nav click
   */
  subMainHeaderClickListener: function() {
    var _this = this;

    $('.main_nav-sub-header-mobile, .main_nav-third-header-mobile').click(function(e){
      e.preventDefault();
      $(this)
        .closest('.' + _this.toggle_level_class + ', .' + _this.sub_toggle_level_class)
        .removeClass(_this.toggle_level_class)
        .removeClass(_this.sub_toggle_level_class);
    });
  },

  /**
   * Close all open drawers on resize
   */
  resizer: function() {
    var _this = this;
    // use smart resizer so it doesn't happen at every pixel
    FCH.$window.smartresize(function(){
      if (FCH.bp.large){
        _this.closeAll();
      }
    });
  },
};
