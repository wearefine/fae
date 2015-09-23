'use strict';

var FCH = {

  /* Listener Arrays */
  resize: [],
  scroll: [],
  ready: [],
  load: [],


  /**
  * @function init Start everything up
  **/
  init: function() {

    // IE detection
    this.IE10 = this.isIE(10);
    this.IE9 = this.isIE(9);
    this.anyIE = (this.IE10 || this.IE9);

    this.breakpoints();

    this.resize.push(this.breakpoints);
    this.ready.push(this.mobileFPS);

    var listeners = ['resize', 'scroll', 'ready', 'load'];
    for(var i = 0; i < listeners.length; i++) {
      this._attachChildListeners( listeners[i] );
    }

    this._attachListeners();
  },

  /**
  * @function setDefault Apply value to variable if it has none
  * @param {var} variable - variable to set default to
  * @param {anything} value - default value to attribute to variable
  */
  setDefault: function(variable, value){
    return (typeof variable === 'undefined') ? value : variable;
  },

  /**
  * @function smoothScroll Nice, unjanky scroll to element
  * @param {jQuery object} target - scroll to the top of this object
  * @param {optional integer} duration {2000} - how long the scroll lasts
  * @param {optional integer} delay {100} - how long to wait after trigger
  * @param {optional integer} offset {0} - additional offset to add to the scrollTop
  */
  smoothScroll: function(target, duration, delay, offset){
    duration = this.setDefault(duration, 2000);
    delay = this.setDefault(delay, 100);
    offset = this.setDefault(offset, 0);

    setTimeout(function(){
      $('html,body').animate({
        scrollTop: target.offset().top + offset
      }, duration);
    }, delay);
  },

  /**
  * @function localStore Store a string locally
  * @param {string} key - accessible identifier
  * @param {string} obj - value of identifier
  */
  localSet: function(key, obj) {
    var value = JSON.stringify(obj);
    localStorage[key] = JSON.stringify(obj);

    return value;
  },

  /**
  * @function localRetrive Retrieve localstorage object value
  * @param {string} key - accessible identifier
  */
  localGet: function(key) {
    if (typeof localStorage[key] !== 'undefined') {
      return JSON.parse(localStorage[key]);
    } else {
      return false;
    }
  },

  /**
  * @function localClear Clear value of localstorage object. If no key is passed, clear all objects
  * @param {optional string} key - accessible identifier
  */
  localClear: function(key){
    return typeof key === 'undefined' ? localStorage.clear() : localStorage.removeItem(key);
  },

  /**
  * @function ieIE check if IE is current browser
  * @param {integer} version
  */
  isIE: function(version) {
    var regex = new RegExp('msie' + (!isNaN(version)?('\\s' + version) : ''), 'i');
    return regex.test(navigator.userAgent);
  },

  /**
  * @function exists check for existence of element on page
  * @param {object} query - JavaScript object
  */
  exists: function(query) {
    return !!document.querySelector(query);
  },

  /**
  * @function breakpoints Provides accessible booleans for fluctuating screensizes
  */
  breakpoints: function() {
    var ww, wh;

    ww = window.innerWidth;
    wh = window.innerHeight;

    FCH.dimensions = {
      ww: ww,
      wh: wh
    };

    FCH.bp = {
      small: ww < 768,
      small_up: ww > 767,
      medium_portrait: ww > 767 && ww < 960,
      medium: ww > 767 && ww < 1025,
      large: ww > 1024
    };
  },

  /**
  * @function hasClass Determine if element has class with vanilla JS
  * @param {object} el
  * @param {string} cls
  * @source http://jaketrent.com/post/addremove-classes-raw-javascript/
  */
  hasClass: function(el, cls) {
    return !!el.className.match(new RegExp('(\\s|^)' + cls + '(\\s|$)'));
  },

  /**
  * @function addClass Add class to element with vanilla JS
  * @param {object} el
  * @param {string} cls
  * @source http://jaketrent.com/post/addremove-classes-raw-javascript/
  */
  addClass: function(el, cls) {
    if (!this.hasClass(el, cls)) {
      el.className = el.className.trim();
      el.className += ' ' + cls;
    }
  },

  /**
  * @function removeClass Remove class from element with vanilla JS
  * @param {object} el
  * @param {string} cls
  * @source http://jaketrent.com/post/addremove-classes-raw-javascript/
  */
  removeClass: function(el, cls) {
    if (this.hasClass(el, cls)) {
      var reg = new RegExp('(\\s|^)' + cls + '(\\s|$)');
      el.className = el.className.replace(reg, ' ');
    }
  },

  /**
  * @function Increase screen performance and frames per second by diasbling pointer events on scroll
  * @source http://www.thecssninja.com/css/pointer-events-60fps
  */
  mobileFPS: function(){
    var scroll_timer,
        body = document.getElementsByTagName('body')[0],
        _this = FCH,
        allowHover = function() {
          return _this.removeClass(body, 'u-disable_hover');
        };

    var FPSScroll = function() {
      clearTimeout(scroll_timer),
      _this.hasClass(body, 'u-disable_hover') || _this.addClass(body, 'u-disable_hover'),
      scroll_timer = setTimeout(allowHover, 500 );
    };

    _this.scroll.push(FPSScroll);
  },


  // Private

  /**
  * @function _attachChildListeners Attach hooks on child objects to the listener arrays
  * @param {string} listener
  */
  _attachChildListeners: function(listener) {
    var kids = Object.keys(FC);

    for(var i = 0; i < kids.length; i++) {
      var child = FC[kids[i]];
      if( child.hasOwnProperty(listener) ) {
        var child_func = child[listener];
        child_func.prototype = child;
        FCH[listener].push( child_func );
      }
    }

  },

  /**
  * @function _callListener Execute listeners using the bundled arrays
  * @param {string} listener What to hear for, i.e. scroll, resize
  * @implied_param FC must be defined
  */
  _callListener: function(listener) {
    var listener_array = this[listener];

    for(var x = 0; x < listener_array.length; x++) {
      listener_array[x].call( listener_array[x].prototype );
    }

  },

  /**
  * @function _throttle fire events more efficiently
  * @param {string} type Listener function to trump
  * @param {string} name New name for listener
  * @param {Object} obj Object to bind/watch (defaults to window)
  * @source https://developer.mozilla.org/en-US/docs/Web/Events/scroll
  */
  _throttle: function(type, name, obj) {
    obj = obj || window;
    var running = false;
    var func = function() {
      if (running) {
        return;
      }
      running = true;
      requestAnimationFrame(function() {
        obj.dispatchEvent(new CustomEvent(name));
        running = false;
      });
    };

    obj.addEventListener(type, func);
  },

  /**
  * @function _attachListeners actually bind the listeners to objects
  */
  _attachListeners: function() {
    var _this = this;
    var listener = 'optimized';

    // Optimized fires a more effective listener but the method isn't supported in all browsers
    if(typeof CustomEvent === 'function') {
      _this._throttle('resize', 'optimizedresize');
      _this._throttle('scroll', 'optimizedscroll');
    } else {
      listener = '';
    }

    window.addEventListener(listener + 'scroll', function() {
      _this._callListener('scroll');
    });
    window.addEventListener(listener + 'resize', function() {
      _this._callListener('resize');
    });
    document.addEventListener('DOMContentLoaded', function() {
      _this._callListener('ready');
    });
    window.addEventListener('load', function() {
      _this._callListener('load');
    });
  },

};

/* Cached jQuery variables */
if(typeof jQuery !== 'undefined') {
  FCH.$body = jQuery('body');
  FCH.$window = jQuery(window);
  FCH.$document = jQuery(document);
}
