var FaeNavigation = {
  current_items: [],

  init: function() {
    this.select_current_nav_item();
    this.update_nav_classes();
    if($('.sticky-table-header').length) {
      this.sticky_table_header();
    }
  },

  select_current_nav_item: function() {
    var self = this;
    var current_base_url = window.location.pathname;
    var url_without_edit_new = current_base_url.replace(/\/new|\/edit/, '');
    $('#main_nav a').each(function(){
      var $this = $(this);
      var link = $this.attr('href');
      if (link === url_without_edit_new || link === current_base_url) {
        $this.addClass('current');
        self.current_items.push($this);
        return false;
      }
    });
  },

  update_nav_classes: function() {
    var self = this;
    $.each(self.current_items, function(index, $el){
      if ($el.hasClass('main_nav-link')) {
        self.update_first_level($el);
      } else if ($el.hasClass('main_nav-sub-link')) {
        self.update_second_level($el);
      } else if ($el.hasClass('main_nav-third-link')) {
        self.update_third_level($el);
      }
    });
  },

  update_first_level: function($el) {
    $el.closest('li').addClass('main_nav-active-single');
  },

  update_second_level: function($el) {
    $el
      .closest('li').addClass('main_nav-sub-active')
      .closest('.main_nav-accordion').removeClass('main_nav-accordion').addClass('main_nav-active');
  },

  update_third_level: function($el) {
    $el
      .closest('li').addClass('main_nav-third-active')
      .closest('.sub_nav-accordion').removeClass('sub_nav-accordion').addClass('main_nav-sub-active--no_highlight')
      .closest('.main_nav-accordion').removeClass('main_nav-accordion').addClass('main_nav-active');
  },

  // If you want to try this in CSS be my guest but it's done near impossible to make a sticky <thead>
  sticky_table_header: function() {
    var headerHeight = $('.main_content-header').outerHeight();

    // Cache offset and height values to spare expensive calculations on scroll
    var sizeFixedHeader = function($el, headerHeight) {
      var $this = $el;
      var tableOffset = $this.offset().top - headerHeight;
      var bottomOffset = $this.height() + tableOffset - $this.find('thead').height();
      var $fixedHeader = $this.next('.sticky-table-header--hidden');

      $fixedHeader.data({
        'table-offset' : tableOffset,
        'table-bottom' : bottomOffset
      });

      $fixedHeader.css({
        width: $this.width(),
        top: headerHeight
      });

      $.each($this.find('thead tr th'), function(ind,val){
        var original_width = $(val).width();
        $($fixedHeader.find('tr > th')[ind]).width(original_width);
      });
    };

    // Add sticky psuedo tables after our main table to hold the fixed header
    $('.sticky-table-header').each(function() {
      var $this = $(this);
      var $header = $this.find('thead').clone();
      var new_classes = $this.attr('class').replace('sticky-table-header', 'sticky-table-header--hidden');

      var $fixedHeader = $('<table />', {
        class: new_classes
      });

      $fixedHeader.append( $header );
      $this.after($fixedHeader);

      sizeFixedHeader($this, headerHeight);
    });

    // If the table header is in range, show it, otherwise hide it
    $(window).on('scroll', function() {
      var offset = $(this).scrollTop();

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
    });

    // Get all values squared away again if the viewport gets smaller
    $(window).on('resize', function() {

      var headerHeight = $('.main_content-header').outerHeight();
      $('.sticky-table-header').each(function() {
        sizeFixedHeader($(this), headerHeight);
      });

    });

  }
}