/* global Fae, FrobCoreHelpers, judge */

// This is a separate file to keep application.js pure
;(function() {
  // FCH dispatches the throttled window scroll, resize and load events to the modules that define those hooks
  window.FCH = new FrobCoreHelpers(Fae, {
    mobile_fps: false
  });

  /**
   * Initialize the admin UI inside `root`. Safe to call repeatedly: on page load, after AJAX has swapped in
   * new markup, and (with Turbo) after a render. Elements and listeners that are already set up are skipped.
   *
   * Dispatches a bubbling `fae:load` event on the root element when it's done, with `{ root }` as the detail.
   * Host JavaScript hooks in by listening for it (see docs/topics/custom_js_css.md).
   * @param {Element|jQuery|Document} [root=document]
   */
  Fae.init = function(root) {
    var $root = $(root || document);

    if ($root[0] === document) {
      initializedBody = document.body;
    }

    judge.enginePath = Fae.path + '/judge';

    if ($.trumbowyg) {
      $.trumbowyg.svgPath = Fae.config('trumbowyg-icons');
    }

    Fae.form.init($root);
    Fae.navigation.init($root);
    Fae.modals.init();
    Fae.tables.init();
    Fae.altTextManager.init();

    // FCH only dispatches `load` once, so catch up when initializing after the window has loaded
    if (document.readyState === 'complete') {
      Fae.navigation.load();
    }

    $root[0].dispatchEvent(new CustomEvent('fae:load', { bubbles: true, detail: { root: $root[0] } }));
  };

  // Turbo swaps the <body> on every visit but keeps this script (and its window and document listeners) alive,
  // so each new body is initialized fresh. Content loaded into a <turbo-frame> is initialized on its own.
  var initializedBody = null;

  document.addEventListener('turbo:load', function() {
    // The first turbo:load fires for the page this script already initialized
    if (document.body !== initializedBody) { Fae.init(); }
  });

  document.addEventListener('turbo:frame-load', function(event) {
    Fae.init(event.target);
  });

  // A replaced body is discarded without jQuery knowing, so release its data, its date range pickers and any open
  // modal. That has to wait until the body really was replaced: Turbo also dispatches before-render and render for the
  // second pass of a redirected visit, which re-renders nothing, and cleaning then would strip the live page.
  var outgoingBody = null;

  document.addEventListener('turbo:before-render', function() {
    outgoingBody = document.body;
  });

  document.addEventListener('turbo:render', function() {
    var discarded = outgoingBody;
    outgoingBody = null;

    if (!discarded || discarded === document.body) { return; }

    if (Fae.modals.modalOpen) {
      $.modal.close();
      Fae.modals.modalOpen = false;
    }

    Fae.form.dates.destroyDateRangePickers(discarded);
    $.cleanData([discarded].concat($.makeArray(discarded.getElementsByTagName('*'))));
  });

  // The scripts load in <head>, so the DOM isn't ready yet
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function() { Fae.init(); });
  } else {
    Fae.init();
  }
})();
