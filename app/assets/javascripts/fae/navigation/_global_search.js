/* global Fae, FCH */

'use strict';

/**
 * Fae global search
 * @namespace globalSearch
 * @memberof Fae
 */
Fae.globalSearch = {

  init: function() {
    this.$wrapper = $('#js-utility-search-wrapper');
    this.$input = $('#js-global-search');

    this.utilitySearch();
    this.searchListener();
  },

  /**
   * Click event of the admin search in the main nav
   */
  utilitySearch: function() {
    var _this = this;
    var $header = $('#js-main-header');
    var timer;

    /**
     * Hide search menu, unbind listener, and blur the input
     * @private
     */
    function hideSearch() {
      // Avoid duplicate/rapid bindings
      $header.off('mouseleave', hideSearch);
      _this.$wrapper.hide();
      _this.$input.blur();
    }

    // If user leaves search, remove menu
    _this.$wrapper.on('mouseleave', hideSearch);

    // Hover over search icon
    $('#js-utility-search').mouseover(function() {
      // Reset timeout
      clearTimeout(timer);
      $header.on('mouseleave', hideSearch);

      // Hover intent
      // If user gets from header to search within .8s, they can pass over other icons
      // but after .8s, the search menu will disappear if they leave the area
      timer = setTimeout(function() {
        $header.off('mouseleave', hideSearch);
      }, 800);

      _this.$wrapper.show();
      _this.$input.focus();
    });
  },

  /**
   * Applies keyup listener on search input to handle live results and navigation
   */
  searchListener: function() {
    var _this = this;
    var ignored_keycodes = [16, 17, 18, 20];
    var arrow_keycodes = [37, 38, 39, 40];

    _this.$input.on('keyup', function(ev) {
      // handle arrow keys
      if (arrow_keycodes.indexOf(ev.keyCode) >= 0) {
        _this.moveSelection(ev.keyCode);
        return;
      }

      // handle enter key
      if (ev.keyCode === 13) {
        // if there's a highlighted result, redirect to it's href
        var $current_link = $('.js-search-results a.-current');
        if ($current_link.length) {
          window.location = $current_link.attr('href');
        }
        return;
      }

      // ignore keys that won't change the result set
      if (ignored_keycodes.indexOf(ev.keyCode) >= 0) {
        return;
      }

      // otherwise update the live search
      var post_url = Fae.path + '/search/' + _this.$input.val();
      $.post(post_url, function(data) {
        _this.$wrapper.find('ul').replaceWith(data);
      });
    });
  },

  /**
   * Updates the selected result
   * @param {Number} keyCode - the key pressed
   */
  moveSelection: function(keyCode) {
    var $result_links = $('.js-search-results a');
    var $current_link = $('.js-search-results a.-current');
    var current_index = $.inArray($current_link[0], $result_links);

    // handle up and left arrow keys
    if (keyCode === 37 || keyCode === 38) {
      if (current_index <= 0) {
        current_index = $result_links.length - 1;
      } else {
        current_index -= 1
      }
    }

    // handle down and right arrow keys
    if (keyCode === 39 || keyCode === 40) {
      if (current_index + 1 >= $result_links.length) {
        current_index = 0;
      } else {
        current_index += 1
      }
    }

    // move current class to new selection
    $current_link.removeClass('-current');
    $result_links.eq(current_index).addClass('-current');
  },

};
