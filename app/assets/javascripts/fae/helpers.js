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

//debounce a la David Walsh
function debounce(a,b,c){var d;return function(){var e=this,f=arguments;clearTimeout(d),d=setTimeout(function(){d=null,c||a.apply(e,f)},b),c&&!d&&a.apply(e,f)}}