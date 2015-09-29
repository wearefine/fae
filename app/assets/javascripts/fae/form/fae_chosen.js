'use strict';

(function ( $ ) {
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
    });

  };

}( jQuery ));
