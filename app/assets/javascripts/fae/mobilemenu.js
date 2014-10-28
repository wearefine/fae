var MobileMenu = {
  mobile_container: "#main_nav",
  trigger_selector: "#main_nav-menu_button",
  header_selector: ".main_nav-header",
  sub_header_selector: ".main_nav-sub-header-mobile",
  sub_header_section_selector: ".main_nav-sub-nav",
  toggle_class: "js-menu-active",
  toggle_level_class: "js-menu-level-active",
  drawer_closed: true,
  default_screen_width: 1024,

  init: function(){
    this.open_drawer();
    this.header_clicks();
    this.resizer();
    this.sub_header_clicks();
    this.link_clicks();

    //get a reference to the trigger
    this.$trigger = $(this.trigger_selector);
  },

  open_drawer: function() {
    var that = this;

    $(this.trigger_selector).click(function(e){
      e.preventDefault();
      var $html = $("html");
      // check to see if the html has the toggle class...which means it's opened
      if ($html.hasClass(that.toggle_class)) {
        that.close_all();
      } else {
        $("html").addClass(that.toggle_class);
      }
    });
  },

  close_all: function() {
    // remove the HTML class which closes the first level
    $("html").removeClass(this.toggle_class);

    // remove the class if a second level item is opened
    $(this.header_selector).closest("li").removeClass(this.toggle_level_class);
  },

  link_clicks: function() {
    var that = this;

    $(this.mobile_container).find("a").click(function(){
      that.close_all();
    });
  },

  header_clicks: function() {
    var that = this;
    // close the menus if clicked on an actual link
    $(this.header_selector).click(function(e){
      if (!$(this).hasClass("js-menu-header-active") && $(window).width() < that.default_screen_width) {
        e.preventDefault();
        var $parent = $(this).closest("li");
        var link_url = $(this).data("link");

        // 
        $parent.addClass(that.toggle_level_class);

        if ($parent.find(that.sub_header_section_selector).length === 0 && typeof link_url !== "undefined") {
          location.href = link_url;
        }
      }
    });
  },

  sub_header_clicks: function() {
    var that = this;
    $(this.sub_header_selector).click(function(e){
      e.preventDefault();
      $("." + that.toggle_level_class).removeClass(that.toggle_level_class);
    });
  },

  resizer: function() {
    var that = this;
    // use smart resizer so it doesn't happen at every pixel
    $(window).smartresize(function(){
      if ($(window).width() >= that.default_screen_width){
        that.close_all();
      }
    });
  },
};

$(function() {
  MobileMenu.init();
});