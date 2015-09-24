/* global Fae */

'use strict';

Fae.navigation = {
  current_items: [],

  init: function() {
    this.select_current_nav_item();
    this.update_nav_classes();
    this.subnavHighlighter.init();
    this.mobileMenu.init();
    this.utilityNav();
    this.buttonDropdown();
    this.fade_notices();
    this.language.init();
  },

  select_current_nav_item: function() {
    var self = this;
    var current_base_url = window.location.pathname;
    var url_without_edit_new = current_base_url.replace(/\/new|\/edit/, '').split('/')[2];
    $('#main_nav a').each(function(){
      var $this = $(this);
      var link = $this.attr('href');
      if ((link.indexOf(url_without_edit_new) > -1) || link === current_base_url) {
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

  // utility nav drop down
  utilityNav: function() {
    $('.utility_nav-user > a, .utility_nav-view > a').on('click', function(e) {
      e.preventDefault();
      e.stopPropagation();
      var $sub_nav = $(this);

      // there could be more than one. so remove all of the clicked statuses and add to the specific one
      $('.utility_nav-clicked').removeClass('utility_nav-clicked');
      $sub_nav.addClass('utility_nav-clicked');

      // assign a once function to close the menus
      $(document).on('click.utility_nav', function(e){
        // as long as the click is not in the menu
        if ($(e.target).closest('.utility_sub_nav').length === 0) {
          // remove the class from the utility nav
          $sub_nav.removeClass('utility_nav-clicked');

          // unbind the click from the document, no need to keep it around.
          $(document).off('click.utility_nav');
        }
      });
    });
  },

  buttonDropdown: function() {

    // button dropdown class toggle
    $(".button-dropdown").click(function(){
      $(this).toggleClass("button-dropdown--opened");
    });

    // button dropdown click anywhere but the dropdown close
    $("body").click(function(e){
      if ($(e.target).closest(".button-dropdown").length === 0) {
        $(".button-dropdown").removeClass("button-dropdown--opened");
      }
    });
  },

  fade_notices: function() {
    $('.notice, .alert, .error').not('.input .error').delay(3000).slideUp('fast');
  },
}
