// Object.create support test, and fallback for browsers without it *cough*ie8*cough*
if (typeof Object.create !== "function") {
  Object.create = function (o) {
    function F() {}
    F.prototype = o;
    return new F();
  };
}

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

// a throttling function for some scrolling
function throttle(fn, threshhold, scope) {
  threshhold || (threshhold = 250);
  var last,
      deferTimer;
  return function () {
    var context = scope || this;

    var now = +new Date,
        args = arguments;
    if (last && now < last + threshhold) {
      // hold on to it
      clearTimeout(deferTimer);
      deferTimer = setTimeout(function () {
        last = now;
        fn.apply(context, args);
      }, threshhold);
    } else {
      last = now;
      fn.apply(context, args);
    }
  };
}
