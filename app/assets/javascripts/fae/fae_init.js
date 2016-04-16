/* global Fae, FCH */

// This is a separate file to keep application.js pure
;(function() {
  FCH.init(Fae);

  // Selector to support pre-1.3 changes
  // @depreciation - replace Fae.content_selector property and all instances of it with '.content' in v2.0
  Fae.content_selector = FCH.exists('.main_content-section') || FCH.exists('.main_content-sections') ? '.main_content-section-area' : '.content';
})();
