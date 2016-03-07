/* global Fae, FCH, Cookies */

'use strict';

/**
 * Fae tables
 * @namespace tables
 * @memberof Fae
 */
Fae.tables = {

  /**
   * Base cookie string for sorting per site per page
   * @type {String}
   * @see {@link tables.defaultSortCookie}
   * @see {@link tables.columnSorting}
   * @see {@link tables.sortColumnsFromCookies}
   * @depreciation remove sort_selector conditionals in v2.0
   */
  sort_cookie_name: 'Fae_table_sort_preferences',

  init: function() {
    if (FCH.exists('.main_table-sort_columns')) {
      this.dateColumnSorting();
      this.columnSorting();
      this.defaultSortCookie();
      this.sortColumnsFromCookies();
    }

    var sort_selector = '.sortable-handle';
    if (!FCH.exists(sort_selector)) {
      sort_selector = '.main_content-sortable-handle';
    }

    if (FCH.exists(sort_selector)) {
      this.rowSorting(sort_selector);
    }

    this.stickyTableHeader();

    if (FCH.exists('.collapsible')) {
      this.collapsibleTable();
    }

    if (FCH.exists('form ' + Fae.content_selector)) {
      this.endingSelectShim(Fae.content_selector);
    }

    this.addToTable();
  },

  /**
   * Sort columns in tables if applicable
   */
  columnSorting: function() {
    var _this = this;
    var path = window.location.pathname;
    var cookie_value = Cookies.getJSON(_this.sort_cookie_name);

    $('.main_table-sort_columns')
      .tablesorter()
      .on('sortEnd', function(e) {
        var $this = $(this);
        cookie_value = Cookies.getJSON(_this.sort_cookie_name);
        var idx = $this.index() - 1;

        // Create object if the index isn't available at this path
        if (!cookie_value[path].hasOwnProperty(idx)) {
          cookie_value[path][idx] = {};
        }

        // Insert the sort data at the index of the table in the array
        cookie_value[path][idx] = $this.data('tablesorter').sortList;

        // Save it to the cookie as a string
        Cookies.set(_this.sort_cookie_name, cookie_value);
      });
  },

  /**
   * Add smart sorting for dates
   * @has_test {features/date_sort_spec.rb}
   */
  dateColumnSorting: function() {
    $.tablesorter.addParser({
      id: 'mmddyy',
      is: function(s) {
        // testing for ##-##-#### or ####-##-##, so it's not perfect; time can be included
        return (/(^\d{1,2}[\/\s]\d{1,2}[\/\s]\d{2})/).test((s || '').replace(/\s+/g, ' ').replace(/[\-.,]/g, '/'));
      },
      format: function(s, table, cell, cellIndex) {
        if (s) {
          var c = table.config,
            ci = c.$headers.filter('[data-column=' + cellIndex + ']:last'),
            format = ci.length && ci[0].dateFormat || $.tablesorter.getData( ci, $.tablesorter.getColumnData( table, c.headers, cellIndex ), 'dateFormat') || c.dateFormat;
          s = s.replace(/\s+/g, ' ').replace(/[\-.,]/g, '/'); // escaped - because JSHint in Firefox was showing it as an error
          if (format === 'mmddyy') {
            s = s.replace(/(\d{1,2})[\/\s](\d{1,2})[\/\s](\d{2})/, '$3/$1/$2');
          }
        }
        return s ? $.tablesorter.formatFloat( (new Date(s).getTime() || s), table) : s;
      },
      type: 'numeric'
    });
  },

  /**
   * Ensure this page has a key in the table sort hash cookie
   */
  defaultSortCookie: function() {
    var path = window.location.pathname;
    var cookie_value = Cookies.getJSON(this.sort_cookie_name);

    // If cookie hasn't been created for this session
    if (!cookie_value || $.isEmptyObject(cookie_value)) {
      cookie_value = {};
    }

    // Create hash object for this path if it hasn't been done yet
    if (!cookie_value.hasOwnProperty(path)) {
      cookie_value[path] = {};
    }

    Cookies.set(this.sort_cookie_name, cookie_value);
  },

  /**
   * Sort column by stored cookie
   * @has_test {requests/fae_table_sort_spec.rb}
   */
  sortColumnsFromCookies: function() {
    var _this = this;
    var path = window.location.pathname;
    var cookie_value = Cookies.getJSON(_this.sort_cookie_name);

    // Exit early if sort cookie is nothing or there's no cookie at the present path
    if (!cookie_value || $.isEmptyObject(cookie_value) || !cookie_value[path] || $.isEmptyObject(cookie_value[path])) {
      return;
    }

    $('.main_table-sort_columns').each(function(idx) {
      // If this table exists in the cookie hash
      if (cookie_value[path].hasOwnProperty(idx)) {
        // Use array value within another array because of how tablesorter accepts this argument
        $(this).trigger('sorton', [ cookie_value[path][idx] ]);
      }
    });
  },

  /**
   * Make table rows draggable by user
   * @param {String} sort_selector - handle selector
   * @depreciation remove sort_selector arg in v2.0
   */
  rowSorting: function(sort_selector) {
    var content_selector = '.main_content-sortable';

    $(content_selector).sortable({
      items: 'tbody tr',
      opacity: 0.8,
      handle: (sort_selector),

      //helper funciton to preserve the width of the table row
      helper: function(e, $tr) {
        var $originals = $tr.children();
        var $helper = $tr.clone();
        var $ths = $tr.closest('table').find('th');

        $helper.children().each(function(index) {
          // Set helper cell sizes to match the original sizes
          $(this).width($originals.eq(index).width());
          //set the THs width so they don't go collapsey
          $ths.eq(index).width($ths.eq(index).width());
        });

        return $helper;
      },

      // on stop, set the THs back to no inline width for repsonsivity
      stop: function(e, ui) {
        $(ui.item).closest('table').find('th').css('width', '');
      },

      update: function() {
        var $this = $(this);
        var serial = $this.sortable('serialize');
        var object = serial.substr(0, serial.indexOf('['));

        $.ajax({
          url: Fae.path+'/sort/'+object,
          type: 'post',
          data: serial,
          dataType: 'script',
          complete: function(request){
            // sort complete messaging can go here
          }
        });
      }
    });
  },

  /**
   * Enable collapsible tables by clicking the h3 preceding a table. Also enables open/close all
   */
  collapsibleTable: function() {
    var $collapsible = $('.collapsible');
    var $toggle = $('.collapsible-toggle');
    var _this = this;

    // If there's only one table, don't bother with collapsing everything
    // Also, remove the open/close all toggle and the table subheaders
    if ($collapsible.length === 1) {
      $collapsible.removeClass('collapsible');
      $collapsible.find('h3').remove();
      $toggle.remove();

      return;
    }

    $toggle.click(function() {
      var $this = $(this);

      if ($this.hasClass('close-all')) {
        $this.text('Open All');
        $collapsible.removeClass('active');

      } else {
        $this.text('Close All');
        $collapsible.addClass('active');

      }

      Fae.tables.sizeFixedHeader();

      $this.toggleClass('close-all');
    });

    $('.collapsible h3').click(function() {
      var $this = $(this);
      /** @type {Boolean} */
      var toggleHasCloseAll = $toggle.hasClass('close-all');

      $this.parent().toggleClass('active');

      // Change toggle messaging as appropriate
      // First check if there are open drawers
      if ($('.collapsible.active').length > 1) {

        // Change toggle text if it isn't already close all
        if(!toggleHasCloseAll) {
          $toggle.text('Close All');
          $toggle.addClass('close-all');
        }
      } else {

        // Change toggle text if it isn't already open all
        if(toggleHasCloseAll) {
          $toggle.text('Open All');
          $toggle.removeClass('close-all');
        }
      }

      Fae.tables.sizeFixedHeader();
    });
  },

  /**
   * Add extra space if the last item in a form is a select menu so the dropdown doesn't run off the screen or section
   * @param {String} selector - Last of type element to target
   * @deprecation remove selector arg in v2.0
   */
  endingSelectShim: function(selector) {
    $('form ' + selector + ':last-of-type').each(function() {
      var $last_item = $(this).find('.input:last-of-type');

      if( $last_item.hasClass('select') ) {
        $(this).addClass('-bottom-shim');
      }
    });
  },

  /**
   * Fix a table header to the top of the view on scroll
   */
  stickyTableHeader: function() {
    var $sticky_tables = $('.content table:not(.stuck-table)');

    // Add sticky psuedo tables after our main table to hold the fixed header
    $sticky_tables.each(function() {
      var $this = $(this);
      var $header = $this.find('thead').clone();

      var $fixedHeader = $('<table />', {
        class: 'sticky-table-header--hidden stuck-table'
      });

      $fixedHeader.append( $header );
      $this.after($fixedHeader);
    });

    /**
     * FCH callback for scroll - If the table header is in range, show it, otherwise hide it
     * @private
     */
    function stickyTableHeaderScroll() {
      var offset = FCH.$window.scrollTop();

      $('.sticky-table-header--hidden').each(function() {
        var $this = $(this);
        var tableOffset = $this.data('table-offset');
        var tableBottom = $this.data('table-bottom');

        if (offset >= tableOffset && offset <= tableBottom) {
          $this.show();
        } else {
          $this.hide();
        }
      });
    }

    FCH.load.push( Fae.tables.sizeFixedHeader );
    FCH.resize.push( Fae.tables.sizeFixedHeader );
    FCH.scroll.push(stickyTableHeaderScroll);
  },

  /**
   * Cache offset and height values to spare expensive calculations on scroll
   * @depreciation remove ternary for header_height variable in v2.0
   */
  sizeFixedHeader: function() {
    var $tables = $('.content table');
    var header_height = FCH.exists('.js-content-header') ? $('.js-content-header').outerHeight() : $('.main_content-header').outerHeight();
    if(FCH.large_down) {
      header_height = $('#js-main-header').outerHeight();
    }

    /**
     * Add offset and height values per each table
     * @private
     */
    function applyOffset() {
      var $this = $(this);

      var tableOffset = $this.offset().top - header_height;
      var theadHeight = $this.find('thead').outerHeight();
      var bottomOffset = $this.height() + tableOffset - theadHeight;
      var $fixedHeader = $this.next('.sticky-table-header--hidden');

      // For whatever reason IE9 does not pickup the .sticky plugin
      if(!$('.js-will-be-sticky').length) {
        tableOffset += header_height;
        header_height = 0;
      }

      $fixedHeader.data({
        'table-offset' : tableOffset,
        'table-bottom' : bottomOffset
      });

      $fixedHeader.css({
        width: $this.outerWidth(),
        height: theadHeight,
        top: header_height,
      });

      $this.find('thead tr th').each(function(index){
        var original_width = $(this).outerWidth()
        // Using .width() as a setter is bunk
        $($fixedHeader.find('tr > th')[index]).css('width', original_width);
      });
    }

    $tables.each( applyOffset );
  },

  /**
   * Scroll_to event for non-ajax'd table forms
   */
  addToTable: function() {
    $('.table-add-link-visible').click('on', function(){
      var $parent = $(this).closest('section');

      FCH.smoothScroll($parent.find('tbody tr:last-child'), 500, 100, 90);
    });
  }
};
