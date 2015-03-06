var FaeNavigation = {
  init: function() {
    this.select_current_nav_item();
  },

  select_current_nav_item: function() {
    var current_base_url = window.location.pathname.replace(/\/new|\/edit/, '');
    $('#main_nav a').each(function(){
      var $this = $(this);
      if ($this.attr('href').replace(/\/new|\/edit/, '') === current_base_url) {
        $this.addClass('current');
      }
    });
  }
}