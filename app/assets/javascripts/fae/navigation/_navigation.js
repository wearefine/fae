/* global Fae */

'use strict';

Fae.navigation = {
  current_items: [],

  init: function() {
    this.select_current_nav_item();
    this.update_nav_classes();
    this.subnavHighlighter.init();
    this.mobileMenu.init();
    this.language.init();
  },

  select_current_nav_item: function() {
    var _this = this;
    var current_base_url = window.location.pathname.replace('#', '');
    var $currentLink = $('#main_nav a[href="' + current_base_url + '"]');
    if ($currentLink.length) {
      // Try to find link that matches the URL exactly
      $currentLink.addClass('current');

    } else {
      // If link can't be found, recursively search for it
      this._find_current_nav_recursively(current_base_url);

    }

    _this.update_nav_classes();
  },

  _find_current_nav_recursively: function(mutated_url) {
    // Remove last element of URL
    var url_array = mutated_url.split('/');
    url_array.pop();
    mutated_url = url_array.join('/');

    var $currentLink = $('#main_nav a[href="' + mutated_url + '"]');
    if ($currentLink.length) {
      $currentLink.addClass('current');

    } else {
      // Defend from exceeding call stack (SUPER RECURSION)
      if (url_array.length) {
        // If it can't be found, start over and try again
        this._find_current_nav_recursively(mutated_url);

      }

    }
  },

  update_nav_classes: function() {
    var self = this;

    $('#main_nav a.current').each(function() {
      var $el = $(this);

      if ($el.hasClass('main_nav-link')) {
        self.update_first_level($el);
      } else if ($el.hasClass('main_nav-sub-link')) {
        self.update_second_level($el);
      } else if ($el.hasClass('main_nav-third-link')) {
        self.update_third_level($el);
      }
    });
  },

  update_first_level: function($el) {
    $el.closest('li').addClass('main_nav-active-single');
  },

  update_second_level: function($el) {
    $el
      .closest('li').addClass('main_nav-sub-active')
      .closest('.main_nav-accordion').removeClass('main_nav-accordion').addClass('main_nav-active');
  },

  update_third_level: function($el) {
    $el
      .closest('li').addClass('main_nav-third-active')
      .closest('.sub_nav-accordion').removeClass('sub_nav-accordion').addClass('main_nav-sub-active--no_highlight')
      .closest('.main_nav-accordion').removeClass('main_nav-accordion').addClass('main_nav-active');
  },
}
