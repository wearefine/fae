(function ( $ ) {
  'use strict';

  /**
   * This plugin sets chosen defaults and massages options based on class names.
   * @function external:"jQuery.fn".fae_chosen
   */
  $.fn.fae_chosen = function( options ) {
    var defaults = {
      disable_search_threshold: 10
    };

    var settings = $.extend( {}, defaults, options );

    return this.each(function() {
      var $this = $(this);

      // remove threshold if show_search class is added from `search: true`
      if ($this.hasClass('select-search')) {
        settings.disable_search_threshold = 0;
      }

      $this.chosen(settings);

      // add handling for bottom of viewport / drop-up support
      $this.on('chosen:showing_dropdown', function(event, params) {
        var chosen_container = $(event.target ).next('.chosen-container');
        var dropdown = chosen_container.find('.chosen-drop');
        var results_container_max_height = parseInt(dropdown.find('.chosen-results').css('max-height'));
        var results_container_top_offset = 40; // to account for possibility of chosen search input
        var dropdown_top = dropdown.offset().top - $(window).scrollTop();
        var viewport_height = $(window).height();

        if (dropdown_top + results_container_max_height + results_container_top_offset > viewport_height) {
          chosen_container.addClass('chosen-drop-up');
        }
      });
      $this.on('chosen:hiding_dropdown', function(event, params) {
         $(event.target).next('.chosen-container').removeClass('chosen-drop-up');
      });
    });

  };

}( jQuery ));
