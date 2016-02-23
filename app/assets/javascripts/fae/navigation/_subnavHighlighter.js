/* global Fae, FCH */

'use strict';

/**
 * Fae navigation subnav highlighter
 * @namespace navigation.subnavHighlighter
 * @memberof navigation
 */
Fae.navigation.subnavHighlighter = {
  sectionClass: '.main_content-section',

  init: function() {
    //only run everything if there is a subnav area
    if (FCH.exists('.main_content-header-section-links')) {
      this.FCHListeners();

      //makes the subnav clicks
      this.anchorClickListener();

      // need to add more padding to the bottom to help the scrolling
      $(this.sectionClass).last().css('min-height', FCH.$window.height());
    }
  },

  /**
   * Since subnavHighlighter is not a direct child of Fae and therefore unknown to FCH, these listeners are saved in private functions in this method
   */
  FCHListeners: function() {
    var _this = this;

    /**
     * On scroll, change highlight of nav item. Bread and butter of this subclass.
     * @access private
     */
    var scrollCallback = function() {
      var active_class = 'main_content-header-section-links-active';

      $(_this.sectionClass).each(function(index) {
        var $this = $(this);
        var position = $this.position().top - 28 - FCH.$window.scrollTop();
        var $link = $('a[href=#' + $this.attr('id') + ']').parent();

        $link.removeClass(active_class);
        if (position <= 0 || index === 0) {
          $link.addClass('js-highligher');
        }
      });

      $('.js-highligher').last().addClass(active_class).removeClass('js-highligher');
    };
    FCH.scroll.push(scrollCallback);

    //highlight the first one on page load
    scrollCallback();

    /**
     * On resize, ensure last section is the same as the window height so when we skip to it the label is at the top
     * @access private
     */
    var resizeCallback = function() {
      $(_this.sectionClass).last().css('min-height', FCH.$window.height());
    };
    FCH.resize.push(resizeCallback);
  },

  /**
   * Smooth scrolling on anchor links in the tab area.
   * @fires {@link navigation.subnavHighlighter._scroller}
   */
  anchorClickListener: function() {
    var _this = this;

    $('.main_content-header-section-links a').on('click', function(e) {
      e.preventDefault();
      _this._scroller(this);
    });
  },

  /**
   * Smoothly scroll to destination if it's a link to the current page
   * @access protected
   * @param {Object} el - JavaScript element to scroll to
   * @see {@link navigation.subnavHighlighter.anchorClickListener}
   */
  _scroller: function(el) {
    if (location.pathname.replace(/^\//,'') === el.pathname.replace(/^\//,'') && location.hostname === el.hostname) {
      var $target = $(el.hash);
      $target = $target.length ? $target : $('[name=' + el.hash.slice(1) + ']');

      if ($target.length) {
        FCH.smoothScroll($target, 500, 0, -112)
      }
    }
  },
};
