/* global Fae */

/**
 * Fae scroll position management
 * @namespace scrollPosition
 * @memberof Fae.form
 */
Fae.form.scrollPosition = {
  init: function() {
    console.log('Fae.form.scrollPosition.init()');
    this.captureScrollPosition();
    this.restoreScrollPosition();
  },

  /**
   * Capture scroll position before form submission
   */
  captureScrollPosition: function() {
    $('form').on('submit', function() {
      var scrollPos = window.pageYOffset || document.documentElement.scrollTop;
      
      // Save scroll position to sessionStorage
      sessionStorage.setItem('fae_scroll_position', scrollPos);
    });
  },

  /**
   * Restore scroll position from sessionStorage
   */
  restoreScrollPosition: function() {
    var scrollPos = sessionStorage.getItem('fae_scroll_position');
    
    if (scrollPos) {
      // Use setTimeout to ensure DOM is fully rendered
      setTimeout(function() {
        window.scrollTo(0, parseInt(scrollPos, 10));
        // Clear the stored position after restoring
        sessionStorage.removeItem('fae_scroll_position');
      }, 100);
    }
  }
};
