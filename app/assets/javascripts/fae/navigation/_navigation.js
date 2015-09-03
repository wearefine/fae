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
    var self = this;
    var current_base_url = window.location.pathname;
    var url_without_edit_new = current_base_url.replace(/\/new|\/edit/, '');
    $('#main_nav a').each(function(){
      var $this = $(this);
      var link = $this.attr('href');
      if (link === url_without_edit_new || link === current_base_url) {
        $this.addClass('current');
        self.current_items.push($this);
        return false;
      }
    });
  },

  update_nav_classes: function() {
    var self = this;
    $.each(self.current_items, function(index, $el){
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
