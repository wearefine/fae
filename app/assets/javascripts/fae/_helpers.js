/* global Fae */

'use strict';

Fae.helpers = {

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
