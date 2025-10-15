/* global Fae, FCH */

// This is a separate file to keep application.js pure
;(function() {
  window.FCH = new FrobCoreHelpers(Fae, {
    mobile_fps: false
  });

  // Initialize Fae components when DOM is ready
  $(document).ready(function() {
    // Initialize all Fae modules
    // if (Fae.navigation && Fae.navigation.ready) {
    //   Fae.navigation.ready();
    // }
    // if (Fae.form && Fae.form.ajax && Fae.form.ajax.init) {
    //   Fae.form.ajax.init();
    // }
    // if (Fae.form && Fae.form.form && Fae.form.form.ready) {
    //   Fae.form.form.ready();
    // }
    // if (Fae.tables && Fae.tables.ready) {
    //   Fae.tables.ready();
    // }
    // if (Fae.modals && Fae.modals.ready) {
    //   Fae.modals.ready();
    // }
    // if (Fae.deploy && Fae.deploy.ready) {
    //   Fae.deploy.ready();
    // }
    // if (Fae.contrast && Fae.contrast.ready) {
    //   Fae.contrast.ready();
    // }
    // if (Fae.altTextManager && Fae.altTextManager.ready) {
    //   Fae.altTextManager.ready();
    // }
  });
})();
