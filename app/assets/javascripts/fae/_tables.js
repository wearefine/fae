Fae.tables = {

  init: function() {
    this.columnSorting();
    this.rowSorting();
    if($('.sticky-table-header').length) {
      this.sticky_table_header();
    }
    if($('.collapsible').length) {
      this.collapsible_table();
    }
    if($('form .main_content-section-area').length) {
      this.endingSelectShim();
    }
  },

  columnSorting: function() {
    $.tablesorter.addParser({
      id: 'mmddyy',
      is: function(s) {
        // testing for ##-##-#### or ####-##-##, so it's not perfect; time can be included
        return (/(^\d{1,2}[\/\s]\d{1,2}[\/\s]\d{2})/).test((s || '').replace(/\s+/g," ").replace(/[\-.,]/g, "/"));
      },
      format: function(s, table, cell, cellIndex) {
        if (s) {
          var c = table.config,
            ci = c.$headers.filter('[data-column=' + cellIndex + ']:last'),
            format = ci.length && ci[0].dateFormat || $.tablesorter.getData( ci, $.tablesorter.getColumnData( table, c.headers, cellIndex ), 'dateFormat') || c.dateFormat;
          s = s.replace(/\s+/g," ").replace(/[\-.,]/g, "/"); // escaped - because JSHint in Firefox was showing it as an error
          if (format === 'mmddyy') {
            s = s.replace(/(\d{1,2})[\/\s](\d{1,2})[\/\s](\d{2})/, "$3/$1/$2");
          }
        }
        return s ? $.tablesorter.formatFloat( (new Date(s).getTime() || s), table) : s;
      },
      type: 'numeric'
    });
    // sort columns in tables if applicable
    $('.main_table-sort_columns').tablesorter();
    $('.main_table-sort_columns-cities').tablesorter({
      sortList: [[1,0]]
    });
  },

  rowSorting: function() {
    //Make table Sortable by user
    $(".main_content-sortable").sortable({
      items: "tbody tr",
      opacity: 0.8,
      handle: (".main_content-sortable-handle"),

      //helper funciton to preserve the width of the table row
      helper: function(e, tr) {
        var $originals = tr.children();
        var $helper = tr.clone();
        var $ths = $(tr).closest("table").find("th");

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
        $(ui.item).closest("table").find("th").css("width", "");
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

  collapsible_table: function() {
    $('.collapsible-toggle').click(function() {
      var $this = $(this);

      if($this.hasClass('close-all')) {
        $this.text('Open All');
        $('.collapsible').removeClass('active');
      } else {
        $this.text('Close All');
        $('.collapsible').addClass('active');
      }

      $this.toggleClass('close-all');
    });

    $('.collapsible h3').click(function() {
      var $this = $(this);
      var $toggle = $('.collapsible-toggle');
      var toggleHasCloseAll = $toggle.hasClass('close-all');

      $this.parent().toggleClass('active');

      // Change toggle messaging as appropriate
      // First check if there are open drawers
      if($('.collapsible.active').length > 1) {

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
    });
  },

  endingSelectShim: function() {
    $('form .main_content-section-area:last-of-type').each(function() {
      var $last_item = $(this).find('.input:last-of-type');

      if( $last_item.hasClass('select') ) {
        $(this).addClass('-bottom-shim');
      }
    });
  },

  // Fix a table header to the top of the view on scroll
  sticky_table_header: function() {
    var $sticky_tables = $('.sticky-table-header');
    var sticky_table_header_selector = '.sticky-table-header--hidden';
    var $window = $(window);

    // Cache offset and height values to spare expensive calculations on scroll
    var sizeFixedHeader = function($el) {
      var $this = $el;
      var headerHeight = $('.main_content-header').outerHeight();
      var ww = $window.width();
      if(ww < 1025) {
        headerHeight = $('#main_header').outerHeight();
      }

      var tableOffset = $this.offset().top - headerHeight;
      var theadHeight = $this.find('thead').outerHeight();
      var bottomOffset = $this.height() + tableOffset - theadHeight;
      var $fixedHeader = $this.next(sticky_table_header_selector);

      // For whatever reason IE9 does not pickup the .sticky plugin
      if(!$('.js-will-be-sticky').length) {
        tableOffset += headerHeight;
        headerHeight = 0;
      }

      $fixedHeader.data({
        'table-offset' : tableOffset,
        'table-bottom' : bottomOffset
      });


      $fixedHeader.css({
        width: $this.outerWidth(),
        height: theadHeight,
        top: headerHeight,
      });

      $this.find('thead tr th').each(function(index){
        var original_width = $(this).outerWidth()
        // Using .width() as a setter is bunk
        $($fixedHeader.find('tr > th')[index]).css('width', original_width);
      });
    };

    // Add sticky psuedo tables after our main table to hold the fixed header
    $sticky_tables.each(function() {
      var $this = $(this);
      var $header = $this.find('thead').clone();
      var new_classes = $this.attr('class').replace('sticky-table-header', sticky_table_header_selector.substr(1));

      var $fixedHeader = $('<table />', {
        class: new_classes
      });

      $fixedHeader.append( $header );
      $this.after($fixedHeader);
    });

    // If the table header is in range, show it, otherwise hide it
    $window.on('scroll', function() {
      var offset = $(this).scrollTop();

      $(sticky_table_header_selector).each(function() {
        var $this = $(this);
        var tableOffset = $this.data('table-offset');
        var tableBottom = $this.data('table-bottom');

        if (offset >= tableOffset && offset <= tableBottom) {
          $this.show();
        } else {
          $this.hide();
        }
      });
    });

    // Get all values squared away again if the viewport gets smaller
    $window.on('resize', function() {

      $sticky_tables.each(function() {
        sizeFixedHeader($(this));
      });

    });

    // Because images mess this up too
    $window.on('load', function() {
      $sticky_tables.each(function() {
        sizeFixedHeader($(this));
      });
    });

  }
};
