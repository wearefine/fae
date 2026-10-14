/**
 * Fae
 * @module Fae
 * @namespace Fae
*/
var Fae = {
  /**
   * Admin mount path, read from the layout's `fae-path` meta tag
   * @type {String}
   */
  get path() {
    return Fae.config('path');
  },

  /**
   * Separator the slugger puts between words, read from the `fae-slug-separator` meta tag
   * @type {String}
   */
  get slugSeparator() {
    return Fae.config('slug-separator') || '-';
  },

  /**
   * Read a `<meta name="fae-{name}">` value rendered by the layout
   * @param {String} name
   * @return {String}
   */
  config: function(name) {
    var meta = document.querySelector('meta[name="fae-' + name + '"]');
    return meta ? meta.getAttribute('content') : '';
  },

  /**
   * Narrow a jQuery collection to the elements that haven't been initialized for `key`, and mark them.
   * Every legacy module uses this so `Fae.init` can run any number of times (page load, AJAX swaps, Turbo
   * renders) without binding handlers or building widgets twice. Markers are DOM properties, so they
   * disappear with removed elements and aren't carried over by `clone()`.
   * @param {jQuery} $elements
   * @param {String} key - One key per kind of initialization
   * @return {jQuery}
   */
  fresh: function($elements, key) {
    var marker = 'faeInit_' + key;

    return $elements.filter(function() {
      if (this[marker]) { return false; }

      this[marker] = true;
      return true;
    });
  }
};

/**
 * Run `callback` the first time it's called for `key`. For document, window and FCH listeners, which
 * outlive any one page of content.
 * @param {String} key
 * @param {Function} callback
 */
Fae.once = (function() {
  var ran = {};

  return function(key, callback) {
    if (ran[key]) { return; }

    ran[key] = true;
    callback();
  };
})();
