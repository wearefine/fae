Fae.navigation.mobileMenu = {
  mobile_container: "#main_nav",
  trigger_selector: "#main_nav-menu_button",
  header_selector: ".main_nav-header",
  sub_header_selector: ".main_nav-sub-header-mobile, .main_nav-third-header-mobile",
  sub_header_section_selector: ".main_nav-sub-nav",
  toggle_class: "js-menu-active",
  toggle_level_class: "js-menu-level-active",
  sub_toggle_level_class: "js-sub-menu-level-active",
  drawer_closed: true,
  default_screen_width: 1024,

  init: function(){
    this.open_drawer();
    this.header_clicks();
    this.resizer();
    this.sub_header_clicks();
    this.third_nav_clicks();
    this.link_clicks();

    //get a reference to the trigger
    this.$trigger = $(this.trigger_selector);
  },

  open_drawer: function() {
    var self = this;

    $(this.trigger_selector).click(function(e){
      e.preventDefault();
      var $html = $("html");
      // check to see if the html has the toggle class...which means it's opened
      if ($html.hasClass(self.toggle_class)) {
        self.close_all();
      } else {
        $("html").addClass(self.toggle_class);
      }
    });
  },

  close_all: function() {
    // remove the HTML class which closes the first level
    $("html").removeClass(this.toggle_class);

    // remove toggle_level_class and sub_toggle_level_class classes
    $('.' + this.toggle_level_class).removeClass(this.toggle_level_class);
    $('.' + this.sub_toggle_level_class).removeClass(this.sub_toggle_level_class);
  },

  link_clicks: function() {
    var self = this;

    $(this.mobile_container).find("a").click(function(){
      self.close_all();
    });
  },

  header_clicks: function() {
    var self = this;
    // close the menus if clicked on an actual link
    $(this.header_selector).click(function(e){
      if (!$(this).hasClass("js-menu-header-active") && $(window).width() < self.default_screen_width) {
        e.preventDefault();
        var $parent = $(this).closest("li");
        var link_url = $(this).data("link");

        // Add JS toggle class
        $parent.addClass(self.toggle_level_class);

        // If the element does not have sublinks, then go to the desired page
        if ($parent.find(self.sub_header_section_selector).length === 0 && typeof link_url !== "undefined") {
          location.href = link_url;
        }
      }
    });
  },

  third_nav_clicks: function() {
    var self = this;
    $('.main_nav-sub-link.with-third_nav').click(function(e){
      if ($(window).width() < self.default_screen_width) {
        e.preventDefault();
        e.stopImmediatePropagation();
        $(this).parent().addClass(self.sub_toggle_level_class);
      }
    });
  },

  sub_header_clicks: function() {
    var self = this;
    $(this.sub_header_selector).click(function(e){
      e.preventDefault();
      $(this)
        .closest("." + self.toggle_level_class + ", ." + self.sub_toggle_level_class)
        .removeClass(self.toggle_level_class)
        .removeClass(self.sub_toggle_level_class);
    });
  },

  resizer: function() {
    var self = this;
    // use smart resizer so it doesn't happen at every pixel
    $(window).smartresize(function(){
      if ($(window).width() >= self.default_screen_width){
        self.close_all();
      }
    });
  },
};
