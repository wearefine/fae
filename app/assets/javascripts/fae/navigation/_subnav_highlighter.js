/* global Fae, FCH */

/**
 * Fae navigation subnav highlighter
 * @namespace navigation.subnav_highlighter
 * @memberof navigation
 */
Fae.navigation.subnav_highlighter = {
  init: function() {
    //only run everything if there is a subnav area
    // @depreciation - change conditional to FCH.exists('.content-header-subnav') in v2.0
    if (FCH.exists('.main_content-header-section-links') || FCH.exists('.content-header-subnav')) {
      // @depreciation - remove entire conditional block (following 7 lines) in v2.0
      if(Fae.content_selector === '.content') {
        this.section_class = Fae.content_selector;
        this.subnav_class = '#js-content-header-subnav';
        this.addBuffer();
      } else {
        this.section_class = '.main_content-section';
        this.subnav_class = '.main_content-header-section-links';
      }

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
    var $subnav = $( this.subnav_class );
    var height = $subnav.css('height');
    $subnav.parent().css('padding-bottom', height);
  },

  /**
   * Since subnavHighlighter is not a direct child of Fae and therefore unknown to FCH, these listeners are saved in private functions in this method
   */
  FCHListeners: function() {
    // @depreciation - change value of section_class to '.content' in v2.0
    var section_class = this.section_class;
    // @depreciation - change value of subnav_class to '#js-content-header-subnav' in v2.0
    // Ideally, form_header will include header.content-header.js-content-header
    var subnav_class = this.subnav_class;
    // @depreciation - remove legacy_buffer expression in v2.0 (the value should be 0, so it will be unnecessary)
    var legacy_buffer = section_class === Fae.content_selector ? 0 : 32;

    /**
     * On scroll, change highlight of nav item. Bread and butter of this subclass.
     * @private
     */
    function scrollCallback() {
      var scroll_top = FCH.$window.scrollTop();

      $(section_class).each(function(index) {
        var $this = $(this);
        var position = $this.position().top - scroll_top - legacy_buffer;
        var $link = $('a[href="#' + $this.attr('id') + '"]').parent();

        $link.removeClass('-active');
        if (position <= 0 || index === 0) {
          $link.addClass('js-highligher');
        }
      });

      $('.js-highligher').last().addClass('-active').removeClass('js-highligher');
    }
    FCH.scroll.push(scrollCallback);

    //highlight the first one on page load
    scrollCallback();

    /**
     * On resize, ensure last section is the same as the window height so when we skip to it the label is at the top
     * @private
     */
    function lastSectionBuffer() {
      var last_selector = $( subnav_class + ' li:last-child a').attr('href');
      $(last_selector).css('min-height', FCH.$window.height());
    }
    lastSectionBuffer();
    FCH.resize.push(lastSectionBuffer);
  },

  /**
   * Smooth scrolling on anchor links in the tab area.
   */
  anchorClickListener: function() {
    // @depreciation - replace scroll_offset_selector variable with string '.content-header' in v2.0
    var scroll_offset_selector = FCH.exists('.main_content-header') ? '.main_content-header' : '.content-header';
    var scroll_offset = parseInt( $(scroll_offset_selector).css('height'), 10 );
    // @depreciation - remove should_find_h2 in v2.0
    var should_find_h2 = this.section_class === Fae.content_selector;

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
        // @depreciation - remove conditional wrapping (keep $target = ... and scroll_offset -= ...) in v2.0
        if(should_find_h2 && $target.find('h2').length) {
          $target = $target.find('h2');
          scroll_offset -= 2;
        }

        if ($target.length) {
          FCH.smoothScroll($target, 500, 0, -scroll_offset);
        }
      }
    }

    $(this.subnav_class + ' a').on('click', scroller);
  },
};
