/* global Fae, FCH */

/**
 * Fae global search
 * @namespace global_search
 * @memberof Fae
 */
Fae.navigation.global_search = {

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
      _this.$wrapper.data('hover', 0);
      _this.$wrapper.hide();
      _this.$input.blur();
      // Avoid duplicate/rapid bindings
      $header.off('mouseleave', hideSearch);
    }

    // If user leaves search, remove menu
    _this.$wrapper.on('mouseleave', hideSearch);

    // Search mouseover effects
    $('#js-utility-search')
      // Ensure that the cursor is over the search menu after timeout
      .hover(function() {
        _this.$wrapper.data('hover', 1);
      }, function() {
        _this.$wrapper.data('hover', 0);
      })

      .mouseover(function() {
        // Reset timeout
        clearTimeout(timer);
        $header.on('mouseleave', hideSearch);

        // Hover intent
        // If user gets from header to search within .8s, they can pass over other icons
        // but after .8s, the search menu will disappear if they leave the area
        timer = setTimeout(function() {
          $header.off('mouseleave', hideSearch);

          // If cursor is no long on search, collapse it
          if ( !_this.$wrapper.data('hover') ) {
            hideSearch();
          }
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
      var val = _this.$input.val();
      var post_url = Fae.path + '/search/' + val;

      // Match only values that exist within links - we don't want to highlight the labels
      // Positive lookahead
        // Ignore if > is present (to avoid matches in href=".*">)
        // End at </a> tag (to ensure that we don't highlight any other markup, like the labels)
      // Case insensitive; find all
      var val_regex = new RegExp(val + '(?=[^>]*<\/a>)', 'ig');

      $.post(post_url, function(data) {
        // Wrap query in b tags
        data = data.replace(val_regex, '<b>$&</b>');
        _this.$wrapper.find('ul').replaceWith(data);

        // If only one result, remove border from header nav item (set by the .search-nav-item class)
        if ($('.js-search-results li').length === 1) {
          $('.js-search-results .search-nav-item').removeClass('search-nav-item');
        }
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
