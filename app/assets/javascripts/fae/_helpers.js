/* global Fae */

'use strict';

Fae.helpers = {

  scroll_to: function(to_elm, adjustment) {
    if (typeof adjustment == 'undefined') {
      // set the default adjustment
      adjustment = 130;
    }
    $('html, body').animate({
      scrollTop: $(to_elm).offset().top - adjustment
    }, 500);
  },

  scroller: function(elm) {
    if (location.pathname.replace(/^\//,'') == elm.pathname.replace(/^\//,'') && location.hostname == elm.hostname) {
      var target = $(elm.hash);
      target = target.length ? target : $("[name=" + elm.hash.slice(1) + "]");

      if (target.length) {
        var newScrollTop = target.offset().top - 116;
        $("html, body").animate({ scrollTop: newScrollTop }, 500);
        return false;
      }
    }
  },
};
