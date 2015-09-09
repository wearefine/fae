'use strict';

function Grinder(callback) {
  return this.init(callback);
}

(function () {

  /**
  * @private
  * @function removeValue - delete value based on key
  * @param {string} key - param to target
  * @param {mixed} value - value to delete from param
  */
  var removeValue = function(key, value) {
    var hash = window.location.hash;
    // check for key, anything between key and value, the value itself, and optionally the trailing comma
    var regex_for_value = new RegExp('(' + key + '=.*)(' + value + '\,?)');
    // results come back [<search through value>, <search before value>, <value>]
    var regex_match = hash.match(regex_for_value);
    // replace <search through value> with everything before <value>
    // Key is included in search in case multiple keys have the same value
    hash = hash.replace(regex_match[0], regex_match[1]);

    // Remove trailing commas
    hash = hash.replace(/\,\&/g, '&');
    hash = hash.replace(/\,$/, '');
    hash = hash.replace(/\=\,/g, '=');

    window.location.hash = hash;
  };

  /**
  * @private
  * @function addValue - add value based on key
  * @param {string} key - param to target
  * @param {mixed} value - value to add to param
  * @param {optional boolean} should_replace_value - if false, value will be appended to the param
  */
  var addValue = function(key, value, should_replace_value) {
    var hash = window.location.hash;

    var old_value = param(key);
    var new_value;

    // If it's blank or is the value of the next param
    if(old_value.charAt(0) === '&' || old_value === '') {
      old_value = key + '=';
      new_value = old_value + value;

    } else {
      old_value = key + '=' + old_value;

      // If the value of the param should be replaced, don't append it to the existing value
      new_value = should_replace_value ? (key + '=' + value) : (old_value + ',' + value);
    }

    hash = hash.replace(old_value, new_value);

    window.location.hash = hash;
  };

  /**
  * @private
  * @function removeKey - remove key from hash. Key's value must be removed prior to executing this function
  * @param {string} key - key to search and destroy
  */
  var removeKey = function(key) {
    var hash = window.location.hash;
    var key_search = new RegExp('[?&]' + key + '=', 'g');

    hash = hash.replace(key_search, '');
    // if initial key removed, replace ampersand with question
    hash = hash.replace('#&', '#?');

    window.location.hash = hash;
  }

  /**
  * @private
  * @see documentation in the public `param` function
  */
  var param = function(key) {
    if(!window.location.hash) {
      return '';
    }
    var hash = window.location.hash;
    var search = new RegExp('#.*[?&]' + key + '=([^&]+)(&|$)');
    var key_value = hash.match(search);

    return (key_value ? key_value[1] : '');
  };

  /**
  * @private
  * @function setDefault - Apply value to variable if it has none
  * @param {var} variable - variable to set default to
  * @param {anything} value - default value to attribute to variable
  */
  var setDefault = function(variable, value){
    return (typeof variable === 'undefined') ? value : variable;
  };


  Grinder.prototype = {

    // Very important object holder
    params: {},

    /**
    * @function init - call once to initialize filtering
    * @param {func} hashChangeCallback - called on every hashchange (first argument is the updated params)
    */
    init: function(hashChangeCallback) {
      var _this = this;

      var privateHashChange = function() {
        var params = _this.parse();
        hashChangeCallback.call(this, params);
      };

      window.onhashchange = privateHashChange;

      privateHashChange();

      return this;

    },

    /**
    * @function update - remove key/value if present in hash; add key/value if not present in hash
    * @param {string} key - param key to query against
    * @param {mixed} value - value for param key
    * @param {optional boolean} key_is_required {false} - if the key is not required, it will be removed from the hash
    * @param {optional boolean} should_replace_value {false} - if false, value will be appended to the key
    */
    update: function(key, value, key_is_required, should_replace_value) {
      var hash = window.location.hash;
      key_is_required = setDefault(key_is_required, false);
      should_replace_value = setDefault(should_replace_value, false);

      // Ensure key exists in the hash
      if(hash.indexOf(key) !== -1) {
        var key_value = param(key);

        var regex_for_value = new RegExp(value, 'g');

        // If key_value contains the new value
        if(regex_for_value.test(key_value)) {

          // If key is required, swap it out
          if(key_is_required) {
            addValue(key, value, should_replace_value);

          } else {

            // If the value is blank, remove the original value from the key
            if(value === '') {
              removeValue(key, key_value);

            // Otherwise remove the vanilla value
            } else {
              removeValue(key, value);

            }

            // If key's value is blank, remove it from hash
            if(param(key) === '') {
              removeKey(key);
            }

          }

        // key_value does not contain the new value
        } else {
          addValue(key, value, should_replace_value);

        }

      // Add key if it doesn't exist
      } else {

        if(window.location.hash) {
          window.location.hash += '&' + key + '=' + value;
        } else {
          // Use a question mark if first key
          window.location.hash = '?' + key + '=' + value;
        }

      }

      // Log it to the history
      if (window.history && window.history.pushState) {
        window.history.pushState(null, null, window.location.hash);
      }

    },

    /**
    * @function parse - evaluate the hash
    * @return key/value hash of the hash broken down by params
    */
    parse: function() {
      var hash = window.location.hash;
      var params;

      // clear zombie keys and values
      this.params = {};

      if(window.location.hash && /\?/g.test(hash)) {
        params = hash.split('?')[1];
        params = params.split('&');

        // Separate params into key values
        for(var i = 0; i < params.length; i++) {
          var key_value = params[i].split('=');
          var key = key_value[0];
          var value = key_value[1];

          this.params[key] = value;
        }
      }

      return this.params;
    },

    /**
    * @function convert - change a JSON object into a string for the hash
    * @param {object | string} obj - object to convert
    * @return {string | boolean} to use in window.location.hash. Returns false if param is not object or string
    */
    convert: function(obj) {
      if( obj.constructor === String ) {
        obj = JSON.parse(obj);
      }

      // Escape if we're not dealing with an object
      if( obj.constructor !== Object ) {
        return false;
      }

      var keys = Object.keys(obj);
      // Set start with a ?
      var new_hash = '?';

      // Loop through all keys in the obj
      for(var i = 0; i < keys.length; i++) {
        var key = keys[i];
        var value = obj[keys[i]];

        if( value.constructor === Array ) {
          value = value.join(',');
        }

        // On next key, if it isn't the first, precede with an ampersand
        if(new_hash !== '?') {
          new_hash += '&';
        }

        // Append key/value to new_hash
        new_hash += key + '=' + value;
      }

      return new_hash;
    },

    /**
    * @function merge - wipe out or selectively replace keys in params
    * @param {object | string} obj - query to replace
    * @param {boolean} replace_all {false} - whether or not to blast existing params away or replace only changed keys
    * @return {string} but also updates hash
    */
    merge: function(obj, replace_all) {
      replace_all = setDefault(replace_all, false);
      var new_hash;

      // If it's a string, convert to an object
      if( obj.constructor === String ) {
        obj = JSON.parse(obj);
      }

      if( replace_all ) {
        // Unilaterally make a string based on the params to use
        new_hash = this.convert(obj);

      } else {
        var new_params = this.parse();
        var keys = Object.keys(new_params);

        for(var i = 0; i < keys.length; i++) {
          var key = keys[i];
          var value = new_params[key[i]];

          if(obj.hasOwnProperty(key)) {
            new_params[key] = obj[key];
          }
        }

        new_hash = this.convert(new_params);
      }

      window.location.hash = '#' + new_hash;

      return new_hash;
    },

    /**
    * @function param - retrieve a key's value
    * @param {string} key - param to target
    * @example
    *   window.location.hash = ?color=blue
    *   grinder.param('color') // => 'blue'
    * @return {string} the value of the key
    */
    param: function(key) {
      return param(key);
    },

    /**
    * @function paramPresent - determine if param is blank or undefined
    * @param {string} key - param to target
    * @return boolean
    */
    paramPresent: function(key) {
      var value = this.params[key];
      return (typeof value !== 'undefined' && value !== '');
    },

  };

})();
