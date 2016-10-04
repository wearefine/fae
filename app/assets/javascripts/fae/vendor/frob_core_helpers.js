/*!
 * FrobCoreHelpers v1.1
 * A framework for front (frob) enders (tenders) everywhere
 * MIT License
 */

(function (window, factory) {
  'use strict';

  if (typeof define === 'function' && define.amd) {
    define([], factory(window));
  } else if (typeof exports === 'object') {
    module.exports = factory(window);
  } else {
    window.FrobCoreHelpers = factory(window);
  }

})(window, function factory(window) {
  'use strict';

  var custom_breakpoints;

  var defaults = {
    mobile_fps: true,
    breakpoints: null,
    preserve_breakpoints: true
  };

  /**
   * Holder for responsive breakpoints, set on load and reset on resize
   * @property {Boolean} small - Window width is less than 768
   * @property {Boolean} small_up - Window width is greater than 767
   * @property {Boolean} medium_portrait - Window width is between 767 and 960
   * @property {Boolean} medium - Window width is between 767 and 1025
   * @property {Boolean} large_down - Window width is less than 1024
   * @property {Boolean} large - Window width is greater than 1024
   * @return {Object}
   */
  function defaultBreakpoints(ww) {
    return {
      small: ww < 768,
      small_up: ww > 767,
      medium_portrait: ww > 767 && ww < 960,
      medium: ww > 767 && ww < 1025,
      large_down: ww < 1024,
      large: ww > 1024
    };
  }

    /**
   * Set a callback that merges the default and original breakpoint listeners
   * @protected
   * @param  {Integer} ww - Window width as called back in this.screenSizes
   * @param  {Integer} wh - Window height as called back in this.screenSizes
   * @see  FrobCoreHelpers#screenSizes
   * @return {Object}
   */
  function mergeBreakpoints(ww, wh) {
    var breakpoints_combined = [defaultBreakpoints(ww, wh), custom_breakpoints(ww, wh)];

    // Empty object to hold combined keys. Custom will override default if using same key
    var new_breakpoints = {};

    // Loop through both functions and their keys
    for(var i = 0; i < breakpoints_combined.length; i++) {
      var breakpoint_wrapper = breakpoints_combined[i];
      var keys = Object.keys(breakpoint_wrapper);

      for(var x = 0; x < keys.length; x++) {
        var key = keys[x];

        // Add to object
        new_breakpoints[key] = breakpoint_wrapper[key];
      }
    }

    return new_breakpoints;
  }

  /**
   * Combine default options with custom ones
   * @private
   * @param  {Object} options - Key/value object to override `defaults` object
   * @return {Object}
   */
  function applyDefaults(options) {
    var default_keys = Object.keys(defaults);

    // Loop through default params
    for(var i = 0; i < default_keys.length; i++) {
      var key = default_keys[i];

      // If options does not have the default key, apply it
      if(!options.hasOwnProperty(key)) {
        options[key] = defaults[key];
      }
    }

    return options;
  }

  /**
   * Attach hooks on child objects to the listener arrays
   * @private
   * @param {String} listener - Such as 'resize' or 'load'
   * @param {Object} jsHolder - The main JavaScript object being queried; adds functionality for DOM callbacks to all children
   * @see {@link FCH.init}
   */
  function attachChildListeners(listener, jsHolder) {
    var kids = Object.keys(jsHolder);

    // Go through all child objects on the holder
    for(var i = 0; i < kids.length; i++) {
      var kid = kids[i];
      var child = jsHolder[kid];

      if( child.hasOwnProperty(listener) ) {
        var child_func = child[listener];

        child_func.prototype = child;
        this[listener].push( child_func );
      }
    }
  }

  /**
   * Fire events more efficiently
   * @private
   * @param {String} type - Listener function to trump
   * @param {String} name - New name for listener
   * @param {Object} obj - Object to bind/watch (defaults to window)
   * @see {@link https://developer.mozilla.org/en-US/docs/Web/Events/scroll}
   */
  function throttle(type, name, obj) {
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
  }

  /**
   * Execute listeners using the bundled arrays
   * @private
   * @param {String} listener - What to hear for, i.e. scroll, resize
   */
  function callListener(listener) {
    var listener_array = this[listener];

    for(var x = 0; x < listener_array.length; x++) {
      listener_array[x].call( listener_array[x].prototype );
    }
  }

  /**
   * Actually bind the listeners to objects
   * @private
   */
  function attachListeners() {
    var listener = 'optimized';
    var _this = this;

    // Optimized fires a more effective listener but the method isn't supported in all browsers
    if(typeof CustomEvent === 'function') {
      throttle('resize', 'optimizedresize');
      throttle('scroll', 'optimizedscroll');
    } else {
      listener = '';
    }

    window.addEventListener(listener + 'scroll', function() {
      callListener.call(_this, 'scroll');
    });
    window.addEventListener(listener + 'resize', function() {
      callListener.call(_this, 'resize');
    });
    document.addEventListener('DOMContentLoaded', function() {
      callListener.call(_this, 'ready');
    });
    window.addEventListener('load', function() {
      callListener.call(_this, 'load');
    });
  }

  /**
   * @private
   * @see {@link FrobCoreHelpers#hasClass documentation in the public `hasClass` function}
   */
  function hasClass(el, cls) {
    return !!el.className.match(new RegExp('(\\s|^)' + cls + '(\\s|$)'));
  }

  /**
   * @private
   * @see {@link FrobCoreHelpers#addClass documentation in the public `addClass` function}
   */
  function addClass(el, cls) {
    if (!hasClass(el, cls)) {
      el.className = el.className.trim();
      el.className += ' ' + cls;
    }
  }

  /**
   * @private
   * @see {@link FrobCoreHelpers#removeClass documentation in the public `removeClass` function}
   */
  function removeClass(el, cls) {
    if (hasClass(el, cls)) {
      var reg = new RegExp('(\\s|^)' + cls + '(\\s|$)');
      el.className = el.className.replace(reg, ' ');
    }
  }

  /**
   * Start everything up
   * @class
   * @param {Object} jsHolder - The main JavaScript object being queried; adds functionality for DOM callbacks to all children
   * @param {Object} [options={}] - Custom options
   *   @property {Boolean} [mobile_fps=true] - Attach the scroll listener for `u-disable-hover`
   *   @property {Function} [breakpoints=null] - To set custom breakpoint, pass a function with two args and return a `string: boolean` object
   *     @property {Integer} ww - Window width
   *     @property {Integer} wh - Window height
   *     @return {Object} - key is identifier, i.e. small; value is a comparison, i.e. ww < 767
   *   @property {Boolean} [preserve_breakpoints=true] - Merge custom breakpoints with default breakpoints
   * @example
   * var FC = {
   *   ui: {
   *     resize: function() { ... }
   *   }
   * }
   * new FrobCoreHelpers(FC);
   * @return {FrobCoreHelpers}
   */
  function FrobCoreHelpers(jsHolder, options) {
    options = this.setDefault(options, {});

    var dimensionsBreakpointsListener = this.screenSizes();

    /** @type {Object} */
    this.options = applyDefaults(options);

    /* Listener Arrays */
    /** @type {Array.<function>} */
    this.resize = [];
    /** @type {Array.<function>} */
    this.scroll = [];
    /** @type {Array.<function>} */
    this.ready = [];
    /** @type {Array.<function>} */
    this.load = [];

    // IE detection
    this.IE10 = this.isIE(10);
    this.IE9 = this.isIE(9);
    this.anyIE = (this.IE10 || this.IE9);

    // If we're merging the breakpoints, ensure breakpoints option object exists
    if(this.options.preserve_breakpoints && this.options.breakpoints) {
      custom_breakpoints = this.options.breakpoints;

      // Set the callback
      this.breakpoints = mergeBreakpoints;
    } else {

      // Fallback to the override or the default breakpoints
      this.breakpoints =  this.options.breakpoints || defaultBreakpoints;
    }

    // Init this.dimensions and this.bp
    dimensionsBreakpointsListener();
    this.resize.push( dimensionsBreakpointsListener );

    if(this.options.mobile_fps) {
      this.scroll.push( this.mobileFPS() );
    }

    /* Cached jQuery variables */
    if(typeof jQuery !== 'undefined') {
      /** @type {jQuery} */
      this.$body = jQuery('body');
      /** @type {jQuery} */
      this.$window = jQuery(window);
      /** @type {jQuery} */
      this.$document = jQuery(document);
    }

    var listeners = ['resize', 'scroll', 'ready', 'load'];
    for(var i = 0; i < listeners.length; i++) {
      var listener = listeners[i];
      attachChildListeners.call(this, listener, jsHolder);
    }

    attachListeners.call(this);

    return this;
  }

  FrobCoreHelpers.prototype = {

    /**
     * Apply value to variable if it has none
     * @param {var} variable - variable to set default to
     * @param {*} value - default value to attribute to variable
     * @return {*} Existing value or passed value argument
     */
    setDefault: function(variable, value){
      return (typeof variable === 'undefined') ? value : variable;
    },

    /**
     * Nice, unjanky scroll to element
     * @param {jQuery} $target - Scroll to the top of this object
     * @param {Number} [duration=2000] - How long the scroll lasts
     * @param {Number} [delay=100] - How long to wait after trigger
     * @param {Number} [offset=0] - Additional offset to add to the scrollTop
     */
    smoothScroll: function($target, duration, delay, offset){
      var _this = this;

      duration = this.setDefault(duration, 2000);
      delay = this.setDefault(delay, 100);
      offset = this.setDefault(offset, 0);

      setTimeout(function(){
        var targetOffset = $target.offset().top + offset;

        // Ensure we scroll to bottom of page if target doesn't have enough space below for viewing
        if (_this.$document.outerHeight() < targetOffset + _this.dimensions.wh) {
          targetOffset = _this.$document.outerHeight() - _this.dimensions.wh;
        }

        $('html, body').animate({
          scrollTop: targetOffset
        }, duration);
      }, delay);
    },

    /**
     * Clear value of localstorage object. If no key is passed, clear all objects
     * @param {String} [key] - Accessible identifier
     * @return {Undefined|Boolean} Result of clear or removeItem action
     */
    localClear: function(key){
      try {
        if(typeof key === 'undefined') {
          localStorage.clear();
        } else {
          localStorage.removeItem(key);
        }
      } catch(e) {
        return false;
      }
    },

    /**
     * Retrieve localstorage object value
     * @param {String} key - Accessible identifier
     * @return {String|Object|Boolean} Value of localStorage object or false if key is undefined
     */
    localGet: function(key) {
      // localStorage is unavailable in some incognito/private browsers
      try {
        if(localStorage.getItem(key)) {
          var value = localStorage.getItem(key);

          if(value.indexOf('{') === 0) {
            return JSON.parse( value );
          } else {
            return value;
          }
        } else {
          return false;
        }
      } catch(e) {
        return false;
      }
    },

     /**
     * Store a string locally
     * @param {String} key - Accessible identifier
     * @param {String|Object} obj - Value of identifier
     * @return {String} Value of key in localStorage
     */
    localSet: function(key, obj) {
      var value;

      if(obj.constructor === String) {
        value = obj;
      } else {
        value = JSON.stringify(obj);
      }

      try {
        localStorage.setItem(key, value);
      } catch(e) {
        // noop
      }

      return value;
    },

    /**
     * Check if IE is current browser
     * @param {Number|String} version
     * @return {Boolean}
     */
    isIE: function(version) {
      var regex = new RegExp('msie' + (!isNaN(version)?('\\s' + version) : ''), 'i');
      return regex.test(navigator.userAgent);
    },

    /**
     * Check for existence of element on page
     * @param {String} query - JavaScript object
     * @return {Boolean}
     */
    exists: function(query) {
      return !!document.querySelector(query);
    },

    /**
     * Provides accessible booleans for fluctuating screensizes; only fire when queried
     * @sets this.dimensions
     * @sets this.bp
     * @fires this.breakpoints
     */
    screenSizes: function() {
      var _this = this;

      return function() {
        var ww = window.innerWidth;
        var wh = window.innerHeight;

        /**
         * dimensions
         * @namespace
         * @description Holder for screen size numbers, set on load and reset on resize
         * @property {Number} ww - Window width
         * @property {Number} wh - Window height
         */
        _this.dimensions = {
          ww: ww,
          wh: wh
        };

      /**
       * bp
       * @namespace
       * @description Sets boolean values for screen size ranges
       * @fires this.breakpoints
       * @see {@link defaultBreakpoints}
       * @see {@link mergeBreakpoints}
       */
        _this.bp = _this.breakpoints.call(null, ww, wh);
      };
    },

    /**
     * Determine if element has class with vanilla JS
     * @param {Object} el - JavaScript element
     * @param {String} cls - Class name
     * @see {@link http://jaketrent.com/post/addremove-classes-raw-javascript/}
     * @return {Boolean}
     */
    hasClass: function(el, cls) {
      return hasClass(el, cls);
    },

    /**
     * Add class to element with vanilla JS
     * @param {Object} el - JavaScript element
     * @param {String} cls - Class name
     * @see {@link http://jaketrent.com/post/addremove-classes-raw-javascript/}
     */
    addClass: function(el, cls) {
      return addClass(el, cls);
    },

    /**
     * Remove class from element with vanilla JS
     * @param {Object} el - JavaScript element
     * @param {String} cls - Class name
     * @see {@link http://jaketrent.com/post/addremove-classes-raw-javascript/}
     */
    removeClass: function(el, cls) {
      return removeClass(el, cls)
    },

    /**
     * Goes through all elements and performs function for each item
     * @private
     * @param {Array|String} selector - Array, NodeList or DOM selector
     * @param {Function} callback
     *   @param {Node} item - Current looped item
     *   @param {Integer} index - Index of current looped item
     */
    loop: function(selector, callback) {
      var items;

      if(selector.constructor === Array || selector.constructor === NodeList) {
        items = selector;
      } else {
        items = document.querySelectorAll(selector);
      }

      for(var i = 0; i < items.length; i++) {
        callback( items[i], i );
      }
    },

    /**
     * Increase screen performance and frames per second by diasbling pointer events on scroll
     * @see {@link http://www.thecssninja.com/css/pointer-events-60fps}
     */
    mobileFPS: function(){
      var scroll_timer;
      var body = document.getElementsByTagName('body')[0];

      function allowHover() {
        return removeClass(body, 'u-disable_hover');
      }

      return function() {
        clearTimeout(scroll_timer),
        hasClass(body, 'u-disable_hover') || addClass(body, 'u-disable_hover'),
        scroll_timer = setTimeout(allowHover, 500 );
      };
    },

    /**
     * Fire event only once
     * @param {Function} func - Function to execute on debounced
     * @param {Integer} [threshold=250] - Delay to check if func has been executed
     * @see {@link http://unscriptable.com/2009/03/20/debouncing-javascript-methods/}
     * @example
     *   FCH.resize.push( FCH.debounce( this.resourceConsumingFunction.bind(this) ) );
     * @return {Function} Called func, either now or later
     */
    debounce: function(func, threshold) {
      var timeout;

      return function() {
        var obj = this, args = arguments;

        function delayed () {
          timeout = null;
          func.apply(obj, args);
        }

        if (timeout) {
          clearTimeout(timeout);
        } else {
          func.apply(obj, args);
        }

        timeout = setTimeout(delayed, threshold || 250);
      };
    },

    /**
     * Check for external links, set target blank if external
     */
    blankit: function() {
      var links = document.getElementsByTagName('a');

      for (var i = 0; i < links.length; i++) {
        if ( /^http/.test(links[i].getAttribute('href')) ) {
          links[i].setAttribute('target', '_blank');
        }
      }
    }
  };

  return FrobCoreHelpers;
});
