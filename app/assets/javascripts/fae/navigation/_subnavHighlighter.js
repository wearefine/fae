Fae.navigation.subnavHighlighter = {
  settings: {
    subnavarea: ".main_content-header-section-links",
    active_class: "main_content-header-section-links-active",
    sections: ".main_content-section"
  },

  init: function() {
    //only run everything if there is a subnav area
    if ($(this.settings.subnavarea).length > 0) {
      var that = this;

      //highlight the first one on page load
      this.scroller();

      //makes the subnav clicks
      this.clicker();
      this.resizer();

      // need to add more padding to the bottom to help the scrolling
      $(this.settings.sections).last().css("min-height", $(window).height());

      $(window).on("scroll.highlighter", function(){
        that.scroller();
      });
    }
  },

  resizer: function() {
    var that = this;
    $(window).on("resize", function(){
      $(that.settings.sections).last().css("min-height", $(window).height());
    });
  },

  scroller: function(){
    var that = this;
    var count = $(this.settings.sections).length;

    $(this.settings.sections).each(function(index) {
      var position = $(this).position().top - 28 - $(window).scrollTop();
      var $link = $("a[href=#" + $(this).attr("id") + "]").parent();

      $link.removeClass(that.settings.active_class);
      if (position <= 0) {
        $link.addClass("js-highligher");
      } else if (index === 0) {
        $link.addClass("js-highligher");
      }
    });
    $(".js-highligher").last().addClass(that.settings.active_class);
    $(".js-highligher").removeClass("js-highligher");
  },

  clicker: function() {
    // smooth scrolling on anchor links in the tab area.
      $(this.settings.subnavarea).find("a").on("click", function(e) {
        e.preventDefault();
        Fae.helpers.scroller(this);
      });
  }
};
