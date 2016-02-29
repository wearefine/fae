/* global Fae, FCH */

'use strict';

/**
 * Fae navigation subnav highlighter
 * @namespace navigation.subnavHighlighter
 * @memberof navigation
 */
Fae.navigation.subnavHighlighter = {
  init: function() {
    //only run everything if there is a subnav area
    if (FCH.exists('.main_content-header-section-links')) {
      if(Fae.content_selector === '.content') {
        this.section_class = Fae.content_selector;
      } else {
        this.section_class = '.main_content-section';
      }

      this.FCHListeners();

      //makes the subnav clicks
      this.anchorClickListener();
    }
  },

  /**
   * Since subnavHighlighter is not a direct child of Fae and therefore unknown to FCH, these listeners are saved in private functions in this method
   * @depreciation remove legacy_buffer in v2.0
   */
  FCHListeners: function() {
    var section_class = this.section_class;
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
        var $link = $('a[href=#' + $this.attr('id') + ']').parent();

        $link.removeClass('main_content-header-section-links-active');
        if (position <= 0 || index === 0) {
          $link.addClass('js-highligher');
        }
      });

      $('.js-highligher').last().addClass('main_content-header-section-links-active').removeClass('js-highligher');
    };
    FCH.scroll.push(scrollCallback);

    //highlight the first one on page load
    scrollCallback();

    /**
     * On resize, ensure last section is the same as the window height so when we skip to it the label is at the top
     * @private
     */
    function lastSectionBuffer() {
      var last_selector = $('.main_content-header-section-links li:last-child a').attr('href');
      $(last_selector).css('min-height', FCH.$window.height());
    }
    lastSectionBuffer();
    FCH.resize.push(lastSectionBuffer);
  },

  /**
   * Smooth scrolling on anchor links in the tab area.
   */
  anchorClickListener: function() {
    var scroll_offset = parseInt( $('.main_content-header').css('height') );
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
        if(should_find_h2 && $target.find('h2').length) {
          $target = $target.find('h2');
          scroll_offset -= 2;
        }

        if ($target.length) {
          FCH.smoothScroll($target, 500, 0, -scroll_offset)
        }
      }
    }

    $('.main_content-header-section-links a').on('click', scroller);
  },
};
