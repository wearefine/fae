// Create a plugin based on a defined object
$.plugin = function(name, object) {
  $.fn[name] = function( options ) {
    return this.each(function() {
      if (!$.data(this, name)) {
        $.data(this, name, Object.create(object).init(options, this));
      }
    });
  };
};

//Smart resizer a la paul irish
(function($,sr){

  // debouncing function from John Hann
  // http://unscriptable.com/index.php/2009/03/20/debouncing-javascript-methods/
  var debounce = function (func, threshold, execAsap) {
      var timeout;

      return function debounced () {
          var obj = this, args = arguments;
          function delayed () {
              if (!execAsap)
                  func.apply(obj, args);
              timeout = null;
          }

          if (timeout)
              clearTimeout(timeout);
          else if (execAsap)
              func.apply(obj, args);

          timeout = setTimeout(delayed, threshold || 100);
      };
  };
  // smartresize
  jQuery.fn[sr] = function(fn){  return fn ? this.bind('resize', debounce(fn)) : this.trigger(sr); };

  /* usage:
    $(window).smartresize(function(){
      [code that takes it easy...]
    });
  */
})(jQuery,'smartresize');

