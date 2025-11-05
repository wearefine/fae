/* global Fae, FCH */

// This is a separate file to keep application.js pure
;(function() {
  window.FCH = new FrobCoreHelpers(Fae, {
    mobile_fps: false
  });
})();
