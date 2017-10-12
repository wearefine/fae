/* global Fae, FCH */

/**
 * Fae navigation subnav highlighter
 * @namespace navigation.subnav_highlighter
 * @memberof navigation
 */
Fae.navigation.subnav_highlighter = {
  init: function() {
    //only run everything if there is a subnav area
    if (FCH.exists('.content-header-subnav')) {
      this.addBuffer();

      this.FCHListeners();

      //makes the subnav clicks
      this.anchorClickListener();
    }
  },

  /**
   * Add space above subnav links if they're present
   * @depreciation - Remove this function in favor of a better HTML solution in form_header in a v2.0 refactor.
   */
  addBuffer: function() {
    var $subnav = $( '#js-content-header-subnav' );
    var height = $subnav.css('height');
    $subnav.parent().css('padding-bottom', height);
  },

  /**
   * Since subnavHighlighter is not a direct child of Fae and therefore unknown to FCH, these listeners are saved in private functions in this method
   */
  FCHListeners: function() {
    /**
     * On scroll, change highlight of nav item. Bread and butter of this subclass.
     * @private
     */
    function scrollCallback() {
      var scroll_top = FCH.$window.scrollTop();

      $('.content').each(function(index) {
        var $this = $(this);
        var position = $this.position().top - scroll_top;
        var $link = $('a[href="#' + $this.attr('id') + '"]').parent();
        var is_scrolled_to_bottom = scroll_top >= (FCH.$document.outerHeight() - FCH.dimensions.wh);

        $link.removeClass('-active');
        if (position <= 0 || index === 0 || is_scrolled_to_bottom) {
          $link.addClass('js-highlighter');
        }
      });

      $('.js-highlighter').last().addClass('-active').removeClass('js-highlighter');
    }

    // highlight the first one on page load
    scrollCallback();
    FCH.scroll.push(scrollCallback);
  },

  /**
   * Smooth scrolling on anchor links in the tab area.
   */
  anchorClickListener: function() {
    var scroll_offset = parseInt( $('.content-header').css('height'), 10 );

    /**
     * Smoothly scroll to destination if it's a link to the current page
     * @private
     * @param {Object} el - JavaScript element to scroll to
     */
    function scroller(e) {
      e.preventDefault();

      if (location.pathname.replace(/^\//,'') === this.pathname.replace(/^\//,'') && location.hostname === this.hostname) {
        var $target = $(this.hash);
        $target = $target.length ? $target : $('[name=' + this.hash.slice(1) + ']');

        if($target.find('h2').length) {
          $target = $target.find('h2');
          scroll_offset -= 2;
        }

        if ($target.length) {
          FCH.smoothScroll($target, 500, 0, -scroll_offset);
        }
      }
    }

    $('#js-content-header-subnav a').on('click', scroller);
  },
};
