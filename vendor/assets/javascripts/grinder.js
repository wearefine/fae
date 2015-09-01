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
    // check for value and optionally the trailing comma
    var regex_for_value = new RegExp(value + '(\,?)', 'g');
    hash = hash.replace(regex_for_value, '');

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
  * @param {optional boolean} should_replace_value {false} - if false, value will be appended to the param
  */
  var addValue = function(key, value, should_replace_value) {
    var hash = window.location.hash;
    should_replace_value = setDefault(should_replace_value, false);

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
        console.log('privateHashChange:', params);
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
      console.log('hash: ', hash);
      key_is_required = setDefault(key_is_required, false);

      // Ensure key exists in the hash
      if(hash.indexOf(key) !== -1) {
        var key_value = param(key);

        var regex_for_value = new RegExp(value, 'g');

        // If key_value contains the new value
        if(regex_for_value.test(key_value)) {

          // If key is required, just swap it out
          if(key_is_required) {
            addValue(key, value, true);

          } else {
            removeValue(key, value);

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